namespace eval ai { namespace export * }
namespace eval ai::int { namespace export * }

set ai::db_path "$SCRIPT_PATH/db/ai"
set ai::brainfile "$ai::db_path/brain"
set ai::stupidfile "$ai::db_path/stupid"
# The Swedish word for "is". TODO: make a list of marks
set ai::mark "är"
set ai::last_statement {}

# Initialize
misc::mkdir $ai::db_path
set ai::brain [misc::slurp_file $ai::brainfile]

proc ai::int::remove {topic index} {
    log::debug "removing \"$topic\" ($index) \"[lindex [dict get $ai::brain $topic] $index]\""

    dict set ai::brain $topic [lreplace [dict get $ai::brain $topic] $index $index]
    # Remove the entire topic if there is no opinions about it left
    if {[llength [dict get $ai::brain $topic]] == 0} {
        set ai::brain [dict remove $ai::brain $topic]
    }

    misc::dump_data $ai::brain $ai::brainfile
}

proc ai::learn {match text} {
	set breaks [lsearch -all -regexp $text {[\.|!|\\?]}]
    set end [llength $text]

    # Find the first break after the match (if present)
    foreach break $breaks {
        if {$break > $match} {
            set end $break
        }
    }

    set topic [lindex $text $match-1]
    set opinion [lrange $text $match $end]

    log::debug "new opinion about \"$topic\" : \"$opinion\""
    dict lappend ai::brain $topic $opinion
    misc::dump_data $ai::brain $ai::brainfile
}

proc ai::talk {nick chan topic} {
    set selected [misc::lrandom_index [dict get $ai::brain $topic]]
    set opinion [lindex [dict get $ai::brain $topic] $selected]

    log::debug "$topic ($selected/[expr [llength [dict get $ai::brain $topic]] -1]) : $opinion"
    putserv "PRIVMSG $chan :$nick: $topic $opinion"
    set ai::last_statement [dict create $topic $selected]
}

proc ai::stupid {nick uhost hand chan text} {
    if {[llength $ai::last_statement] != 2} {
        putserv "PRIVMSG $chan :$nick: I don't recall saying anything"
        return
    }

    if {[llength $text] == 0} {
        putserv "PRIVMSG $chan :$nick: Tell me why I'm stupid"
        return
    }

    set topic [dict key $ai::last_statement]
    set index [dict val $ai::last_statement]
    set opinion [lindex [dict get $ai::brain $topic] $index]
    if {$topic == $nick} {
        putserv "PRIVMSG $chan :$nick: you are stupid"
        return
    }

    # Record why we are stupid
    set fd [open $ai::stupidfile a]
    puts $fd "$nick removed \"$opinion\" from \"$topic\" reason \"$text\""
    close $fd

    ai::int::remove $topic $index

    putserv "PRIVMSG $chan :$nick: alright, reported and forgotten.."
    set ai::last_statement {}
}

proc ai::bind {nick chan text} {
    set text [string tolower $text]

	set mark [lsearch $text $ai::mark]
    if {$mark > 0} {
        ai::learn $mark $text
        return
    }

    foreach topic [dict keys $ai::brain] {
        set match [lsearch $text $topic]

        if {$match >= 0} {
            ai::talk $nick $chan [lindex $text $match]
        }
    }
}
