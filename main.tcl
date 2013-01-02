#!/usr/bin/tclsh

set CHANNEL "#bakka"

bind pub - "!bakka" chicken

proc chicken {nick host hand chan text} {
    set chick {
        "    \\"
        "    (o<  BAKKA !!!!"
        " \\_//)"
        "  \_/_)"
        "   _|_"
    }

    foreach line $chick {
        putlog "PRIVMSG $::CHANNEL : $line"
        puthelp "PRIVMSG $::CHANNEL : $line"
    }
}

puts "sourced main.tcl (bakka)"
