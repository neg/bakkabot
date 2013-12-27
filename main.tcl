#!/usr/bin/tclsh

namespace eval bind { namespace export * }

set SCRIPT_PATH [file dirname [file normalize [info script]]]
set PRINT_DEBUG FALSE

source "$SCRIPT_PATH/int.tcl"

set last_friday_time [clock seconds]
bind pub - "!bakka" bind::chicken
bind pubm - * bind::catch_all

proc bind::catch_all {nick uhost hand chan text} {
    friday $nick $chan
}

proc bind::chicken {nick host hand chan text} {
    if {[lsearch $text "*bakka*"] >= 0} {
        # Print the first chicken without output (we know there will be more)
        set chick [get_chicken ""]

        # Separate bakka from other words
        set bakka [lsearch -all $text "bakka"]
        set text [lsearch -inline -all -not $text "bakka"]

        # More then 2 bakka's? Add them without chicken output
        for {set i 0} {$i < [expr [llength $bakka] - 1]} {incr i} {
            set chick [int::lmerge $chick [get_chicken ""]]
        }

        # Add the last chicken together with any potential non-bakka words
        if {$text == ""} {
            set chick [int::lmerge $chick [get_chicken]]
        } else {
            set chick [int::lmerge $chick [get_chicken $text]]
        }

    } elseif {$text == ""} {
        set chick [get_chicken]
    } else {
        set chick [get_chicken $text]
    }

    foreach line $chick {
        putserv "PRIVMSG $chan : $line"
    }
}

proc get_chicken {{text "BAKKA!!!"}} {
    lappend chick \
        "    \\   " \
        "    (o< $text" \
        " \\_//)  " \
        "  \_/_)  " \
        "   _|_  "

        return $chick
}

proc friday {nick chan} {
    variable last_friday_time

    # Check if it's Friday
    set day [clock format [clock seconds] -format "%w"]
    if {$day != 5} {
        return
    }

    # Start by having a very low chance of printing directly after another
    # message, increasing over time to always printing after about one hour.
    set dt [expr [clock seconds] - $last_friday_time]
    set f [expr $dt / 3600.0]
    if { [expr rand()] >= [expr $f * $f] } {
        return
    }

    # Read the file every time, to allow us to add stuff without restarting
    set data [int::parse_file "txt/friday.hidden"]
    putserv "PRIVMSG $chan :$nick: [int::lrandom_element $data]"
    set last_friday_time [clock seconds]
}

puts "sourced main.tcl (bakka)"
