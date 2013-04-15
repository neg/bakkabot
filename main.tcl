#!/usr/bin/tclsh

source int.tcl
namespace eval bind { namespace export * }

bind pub - "!bakka" bind::chicken
bind pub - "!test" bind::test
bind pubm - * bind::catch_all

proc bind::catch_all {nick uhost hand chan text} {
    friday $nick $chan
}

proc bind::test {nick host hand chan text} {
    set data [int::parse_file "txt/test"]
    putserv "PRIVMSG $chan :$nick [int::lrandom_element $data]"
}

proc bind::chicken {nick host hand chan text} {
    if {$text == ""} {
        set msg "BAKKA !!!!"
    } else {
        set msg $text
    }

    lappend chick \
        "    \\" \
        "    (o<  $msg" \
        " \\_//)" \
        "  \_/_)" \
        "   _|_"

    foreach line $chick {
        putserv "PRIVMSG $chan : $line"
    }
}

proc friday {nick chan} {
    # Check if it's Friday
    set day [clock format [clock seconds] -format "%w"]
    if {$day != 5} {
        return
    }

    # This should probably be made into something smarter and a back-off timer might also be needed.
    # Not entirely sure about the tcl entropy either...
    set rand [expr {int(rand()*10)} + 1]
    if {$rand != 10} {
        return
    }

    # Read the file every time, to allow us to add stuff without restarting
    set data [int::parse_file "txt/friday.hidden"]
    putserv "PRIVMSG $chan :$nick: [int::lrandom_element $data]"
}

puts "sourced main.tcl (bakka)"
