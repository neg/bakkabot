#!/usr/bin/tclsh

source int.tcl
namespace eval bind { namespace export * }

set CHANNEL "#bakka"

bind pub - "!bakka" bind::chicken
bind pub - "!test" bind::test

proc bind::test {nick host hand chan text} {
    set data [int::parse_file "txt/test"]
    puthelp "PRIVMSG $::CHANNEL :[int::lrandom_element $data]"
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
        puthelp "PRIVMSG $::CHANNEL : $line"
    }
}

puts "sourced main.tcl (bakka)"
