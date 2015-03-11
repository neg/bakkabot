namespace eval poll { namespace export * }
namespace eval poll::int { namespace export * }

set poll::db_path "$SCRIPT_PATH/db"
set poll::pollfile "$poll::db_path/polls"

set poll::data [misc::slurp_file $poll::pollfile]

proc poll::remove {id} {
    dict unset poll::data $id
}

proc poll::reminder {id minute} {
    if {![dict exists $poll::data $id]} {
        return
    }

    set info [dict get $poll::data $id]
    set nick [dict get $info nick]
    set chan [dict get $info chan]
    set question [dict get $info question]

    putserv "PRIVMSG $chan :Vote on \"$question\" (!vote $id <number>)"
    after [expr $minute * 1000 * 60] [list poll::reminder $id $minute]
}

proc poll::init {nick host hand chan text} {
    set id "bakka-[misc::get_rand_str 5]"

    # hash collision
    if {[dict exists $poll::data $id]} {
        return
    }

    set qmark [string first "?" $text]
    if {$qmark <= 0} {
        putserv "PRIVMSG $chan :$nick: syntax: !poll why is negs mom so fat? 1: foo. 2: bar."
        return
    }
    set question [string range $text 0 $qmark]

    set data [regexp -inline -all -- {(\d+)\: ([^\.]+)\.} $text]
    if {[llength $data] < 6} {
        putserv "PRIVMSG $chan :$nick: syntax: !poll why is negs mom so fat? 1: foo. 2: bar."
        return
    }

    foreach {str index option} $data {
        dict set options $index $option
        dict set votes $index 0
    }

    dict set poll::data $id \
        [dict create \
            nick $nick \
            chan $chan \
            question $question \
            options $options \
            votes $votes \
            voted-nicks [list] \
            voted-hosts [list]]

    putserv "PRIVMSG $chan :$nick created poll $id \"$question\""
    for {set i 1} {$i <= [dict size $options]} {incr i} {
        putserv "PRIVMSG $chan :$i: [dict get $options $i]"
    }
    putserv "PRIVMSG $chan :Show status with !status $id"

    misc::dump_data $poll::data $poll::pollfile
    poll::reminder $id [expr 60 * 24]
}

proc poll::plist {nick host hand chan text} {
    foreach {id attr} $poll::data {
        putserv "PRIVMSG $chan :$id - [dict get $attr question]"
    }
}

proc poll::status {nick host hand chan text} {
    set id [lindex $text 0]

    set info [dict get $poll::data $id]
    set options [dict get $info options]
    set votes [dict get $info votes]

    foreach {index vote} [misc::dictvalsort  $votes -decreasing] {
        putserv "PRIVMSG $chan :$index: [dict get $options $index] ([dict get $votes $index] votes)"
    }
}

proc poll::vote {nick host hand chan text} {
    set id [lindex $text 0]
    set vote [lindex $text 1]

    if {![string is integer $vote]} {
        putserv "PRIVMSG $chan :$nick: vote with \"!poll <id> <number>"
        return
    }

    if {![dict exists $poll::data $id]} {
        putserv "PRIVMSG $chan :$nick: no such poll \"$id\""
        return
    }

    if {([lsearch [dict get $poll::data $id voted-nicks] $nick] >= 0) ||
            ([lsearch [dict get $poll::data $id voted-hosts] $host] >= 0)} {
        putserv "PRIVMSG $chan :$nick: You already voted.."
        return
    }

    set info [dict get $poll::data $id]

    set tmp [dict get $info votes]
    dict incr tmp $vote
    dict set info votes $tmp

    dict lappend info voted-nicks $nick
    dict lappend info voted-hosts $host
    dict set poll::data $id $info

    set vote_cnt [llength [dict get $info "voted-nicks"]]
    putserv "PRIVMSG $chan :$nick: Your vote is registered ($vote_cnt ppl voted so far)"

    misc::dump_data $poll::data $poll::pollfile
}
