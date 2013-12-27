#!/usr/bin/tclsh

set SCRIPT_PATH [file dirname [file normalize [info script]]]
set PRINT_DEBUG FALSE

source "$SCRIPT_PATH/src/misc.tcl"
source "$SCRIPT_PATH/src/log.tcl"
source "$SCRIPT_PATH/src/chicken.tcl"
source "$SCRIPT_PATH/src/friday.tcl"
source "$SCRIPT_PATH/src/streck.tcl"

bind pub - "!bakka" chicken::bind
bind pub - "!streck" streck::add
bind pub - "!strecklist" streck::list
bind pub - "!strecktop" streck::top
bind pubm - * catch_all

proc catch_all {nick uhost hand chan text} {
    friday::bind $nick $chan
    streck::checkbad $nick $chan $text
}

puts "sourced main.tcl (bakka)"
