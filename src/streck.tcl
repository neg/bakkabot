namespace eval streck { namespace export * }
namespace eval streck::int { namespace export * }

bind pub - "!streck" streck::streck
bind pub - "!strecklist" streck::list
bind pub - "!strecktop" streck::top

set streck::logfile "$SCRIPT_PATH/db/strecklog"
set streck::badwords [misc::parse_file "$SCRIPT_PATH/txt/badwords"]
set streck::data [dict create]

# Read back log if it exists
if {[file exists $streck::logfile]} {
    set log [open $streck::logfile r]
    set streck::data [read $log]
    close $log
}

proc streck::checkbad {nick chan text} {
    # Map to try to catch leetspeak and other obfuscations
    set text [string map {0 o 4 a 3 e 1 i "_" "" "-" ""} $text]
    foreach badword $streck::badwords {
        if {[string match -nocase "*$badword*" $text]} {
            set msg "$nick gets a STRECK for talking about $badword"
            putserv "PRIVMSG $chan :$msg"

            dict incr $streck::data [string tolower $nick]
        }
    }
}

proc streck::int::add {nick} {
    set nick [string tolower $nick]

    log::debug "adding streck to $nick"
    dict incr streck::data $nick

    set log [open $streck::logfile w]
    puts -nonewline $log $streck::data
    close $log
}

proc streck::int::get {nick} {
    set nick [string tolower $nick]
    if {![dict exists $streck::data $nick]} {
        return 0
    }
    return [dict get $streck::data $nick]
}

proc streck::add {nick uhost hand chan text} {
    set target [lindex $text 0]

    if {![onchan $target $chan]} {
        putserv "PRIVMSG $chan :I don't know any \"$target\"?"
        return
    }

    putserv "PRIVMSG $chan :$nick gives \"$target\" a STRECK"
    streck::int::add $target
    putserv "PRIVMSG $chan :Poor \"$target\" now has [streck::int::get $target] STRECK"
}

proc streck::top {nick uhost hand chan text} {
    putserv "PRIVMSG $chan :$nick deserves a STRECK for showing the STRECK top"
    streck::int::add $nick

    set i 1
    dict for {key val} [misc::dictvalsort $streck::data -integer -decreasing] {
        if {$i > 3} {
            break
        }
        putserv "PRIVMSG $chan :$i. [format "%-50.50s" $key] $val"
        incr i
    }
}

proc streck::list {nick uhost hand chan text} {
    putserv "PRIVMSG $chan :$nick gets a STRECK in exchange for the STRECK list"
    streck::int::add $nick

    set i 1
    dict for {key val} [misc::dictvalsort $streck::data -integer -decreasing] {
        putserv "PRIVMSG $nick :$i. [format "%-50.50s" $key] $val"
        incr i
    }
}
