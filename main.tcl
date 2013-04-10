#!/usr/bin/tclsh

namespace eval bind { namespace export * }

set CHANNEL "#bakka"

bind pub - "!bakka" bind::chicken

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
        puthelp "PRIVMSG $::CHANNEL : $line"
    }
}

puts "sourced main.tcl (bakka)"
