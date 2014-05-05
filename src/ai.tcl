namespace eval ai { namespace export * }
namespace eval ai::int { namespace export * }

set ai::db_path "$SCRIPT_PATH/db/ai"
set ai::brainfile "$ai::db_path/brain"
set ai::stupidfile "$ai::db_path/stupid"
set ai::blacklistfile "$ai::db_path/blacklist"
# The Swedish word for "is". TODO: make a list of marks
set ai::mark "är"
set ai::last_statement {}

# Initialize
misc::mkdir $ai::db_path
set ai::brain [misc::slurp_file $ai::brainfile]
set ai::blacklist [misc::slurp_file $ai::blacklistfile]

proc ai::int::remove {topic index} {
    log::debug "removing \"$topic\" ($index) \"[lindex [dict get $ai::brain $topic] $index]\""

    dict set ai::brain $topic [lreplace [dict get $ai::brain $topic] $index $index]
    # Remove the entire topic if there is no opinions about it left
    if {[llength [dict get $ai::brain $topic]] == 0} {
        set ai::brain [dict remove $ai::brain $topic]
    }

    misc::dump_data $ai::brain $ai::brainfile
}

proc ai::int::learn {mark topic text} {
	set breaks [lsearch -all -regexp $text {[\.|!|\\?]}]
    set end [llength $text]

    # Find the first break after the mark (if present)
    foreach break $breaks {
        if {$break > $mark} {
            set end $break
        }
    }

    set opinion [lrange $text $mark $end]

    log::debug "new opinion about \"$topic\" : \"$opinion\""
    dict lappend ai::brain $topic $opinion
    misc::dump_data $ai::brain $ai::brainfile
}

proc ai::int::talk {nick chan topic} {
    set selected [misc::lrandom_index [dict get $ai::brain $topic]]
    set opinion [lindex [dict get $ai::brain $topic] $selected]

    log::debug "$topic ($selected/[expr [llength [dict get $ai::brain $topic]] -1]) : $opinion"
    putserv "PRIVMSG $chan :$nick: $topic $opinion"
    set ai::last_statement [dict create $topic $selected]
}

proc ai::int::blacklist {nick chan word} {
    dict unset ai::brain $word
    misc::dump_data $ai::brain $ai::brainfile

    lappend ai::blacklist $word
    misc::dump_data $ai::blacklist $ai::blacklistfile

    putserv "PRIVMSG $chan :$nick: blacklisted topic \"$word\""
}

proc ai::command {nick host hand chan text} {
    set cmd [lindex $text 0]
    set op [lrange $text 1 end]

    switch $cmd {
        "blacklist" {
            ai::blacklist $nick $host $chan [lindex $op 0]
        }
        "stupid" {
            ai::stupid $nick $chan $op
        }
        default {
            putserv "PRIVMSG $chan :$nick: Unknown ai command \"$cmd\""
        }
    }
}

proc ai::blacklist {nick host chan word} {

    if {[lsearch $ai::blacklist $word] >= 0} {
        putserv "PRIVMSG $chan :$nick: \"$word\" already blacklisted"
        return
    }
    if {[lsearch $ai::mark $word] >= 0} {
        putserv "PRIVMSG $chan :$nick: \"$word\" naah .."
        return
    }

    stage::stage $nick $host $chan "ai blacklist of topic \"$word\"" 1 1 \
    [list ai::int::blacklist $nick $chan $word]

}

proc ai::stupid {nick chan text} {
    if {[llength $ai::last_statement] != 2} {
        putserv "PRIVMSG $chan :$nick: I don't recall saying anything?"
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

    putserv "PRIVMSG $chan :$nick: alright, opinion reported and forgotten.."
    set ai::last_statement {}
}

proc ai::learn {nick chan text} {
    set text [string tolower $text]

	# Search for AI mark
	set mark [lsearch $text $ai::mark]
    set topic [lindex $text $mark-1]
    if {($mark > 0) && ([lsearch $ai::blacklist $topic] < 0)} {
        ai::int::learn $mark $topic $text
    }
}

proc ai::talk {nick chan text} {
    set text [string tolower $text]

    # Only talk on friday, TODO: Break this out and align with friday::
    set day [clock format [clock seconds] -format "%w"]
    if {$day != 5} {
        return
    }

    # Check if we know any topic in the text (sentence)
    foreach topic [dict keys $ai::brain] {
        set mark [lsearch $text $topic]
        if {$mark >= 0} {
            ai::int::talk $nick $chan [lindex $text $mark]
            return
        }
    }
}
