#!/usr/bin/tclsh

namespace eval bind { namespace export * }

set SCRIPT_PATH [file dirname [file normalize [info script]]]
set PRINT_DEBUG FALSE

source "$SCRIPT_PATH/src/misc.tcl"
source "$SCRIPT_PATH/src/log.tcl"
source "$SCRIPT_PATH/src/chicken.tcl"
source "$SCRIPT_PATH/src/friday.tcl"

bind pub - "!bakka" chicken::bind
bind pubm - * bind::catch_all

proc bind::catch_all {nick uhost hand chan text} {
    friday::bind $nick $chan
}

puts "sourced main.tcl (bakka)"
