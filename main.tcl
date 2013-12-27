#!/usr/bin/tclsh

namespace eval bind { namespace export * }

set SCRIPT_PATH [file dirname [file normalize [info script]]]
set PRINT_DEBUG FALSE

source "$SCRIPT_PATH/src/misc.tcl"
source "$SCRIPT_PATH/src/log.tcl"
source "$SCRIPT_PATH/src/chicken.tcl"

set last_friday_time [clock seconds]
bind pub - "!bakka" chicken::bind
bind pubm - * bind::catch_all

proc bind::catch_all {nick uhost hand chan text} {
    friday $nick $chan
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
    set data [misc::parse_file "txt/friday.hidden"]
    putserv "PRIVMSG $chan :$nick: [misc::lrandom_element $data]"
    set last_friday_time [clock seconds]
}

puts "sourced main.tcl (bakka)"
