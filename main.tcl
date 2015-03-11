#!/usr/bin/tclsh

set SCRIPT_PATH [file dirname [file normalize [info script]]]
set PRINT_DEBUG TRUE

source "$SCRIPT_PATH/src/misc.tcl"
source "$SCRIPT_PATH/src/stage.tcl"
source "$SCRIPT_PATH/src/log.tcl"
source "$SCRIPT_PATH/src/ascii.tcl"
source "$SCRIPT_PATH/src/streck.tcl"
source "$SCRIPT_PATH/src/ai.tcl"
source "$SCRIPT_PATH/src/poll.tcl"
source "$SCRIPT_PATH/src/help.tcl"

bind pub - "!bakka" ascii::chicken
bind pub - "!hail" ascii::hail
bind pub - "!streck" streck::add
bind pub - "!strecklist" streck::list
bind pub - "!strecktop" streck::top
bind pub - "!agree" stage::agree
bind pub - "!disagree" stage::disagree
bind pub - "!vote" poll::vote
bind pub - "!poll" poll::init
bind pub - "!polls" poll::plist
bind pub - "!status" poll::status
bind pub - "!ai" ai::command
bind pub - "!help" help::print
bind pubm - * catch_all

proc catch_all {nick uhost hand chan text} {
    # Currently we can't learn or talk about bad words
    if {[streck::checkbad $nick $chan $text]} {
        return
    }
    if {[ai::learn $nick $chan $text]} {
        return
    }
    if {[ai::talk $nick $chan $text]} {
        return
    }
}

puts "sourced main.tcl (bakka)"
