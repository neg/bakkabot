namespace eval stage { namespace export * }
namespace eval stage::int { namespace export * }

set stage::data {}

proc stage::unstage {id} {
    dict unset stage::data $id
}

proc stage::timeout {id} {
    if {![dict exists $stage::data $id]} {
        return
    }

    set info [dict get $stage::data $id]
    set nick [dict get $info nick]
    set chan [dict get $info chan]
    set desc [dict get $info desc]

    putserv "PRIVMSG $chan :$nick: stage $id: $desc timed out"
    stage::unstage $id
}

proc stage::stage {nick host chan desc timeout limit callback} {
    set id [string toupper [misc::get_rand_str 10]]
    dict set stage::data $id \
        [dict create \
            nick $nick \
            chan $chan \
            desc $desc \
            votes 0 \
            voted-nicks [list ""] \
            voted-hosts [list ""] \
            limit $limit \
            callback $callback]

    after [expr $timeout * 1000 * 60 * 60] [list stage::timeout $id]
    putserv "PRIVMSG $chan :staged $desc, need $limit vote(s) within $timeout hour(s).\
        Vote with: \"!disagree/!agree $id\""
}

proc stage::int::vote {nick host chan vote id} {
    if {![dict exists $stage::data $id]} {
        putserv "PRIVMSG $chan :$nick: no such stage \"$id\""
        return
    }
    if {([lsearch [dict get $stage::data $id voted-nicks] $nick] >= 0) ||
            ([lsearch [dict get $stage::data $id voted-hosts] $host] >= 0)} {
        putserv "PRIVMSG $chan :$nick: I remember you ..."
        return
    }

    set info [dict get $stage::data $id]
    dict incr info votes $vote
    dict lappend info voted-nicks $nick
    dict lappend info voted-hosts $nick
    dict set stage::data $id $info

    if {[dict get $info votes] >= [dict get $info limit]} {
        putserv "PRIVMSG $chan :$nick: [dict get $info desc] ($id) approved"
        stage::unstage $id
        eval [dict get $info callback]
    } else {
        putserv "PRIVMSG $chan :$nick: stage $id status \
            [dict get $info votes]/[dict get $info limit]"
    }
}

proc stage::agree {nick host hand chan text} {
    set id [lindex $text 0]
    stage::int::vote $nick $host $chan "+1" $id
}

proc stage::disagree {nick host hand chan text} {
    set id [lindex $text 0]
    stage::int::vote $nick $host $chan "-1" $id
}

