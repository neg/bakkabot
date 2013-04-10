#!/usr/bin/tclsh

set CHANNEL "#bakka"

bind pub - "!bakka" chicken

proc chicken {nick host hand chan text} {
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
