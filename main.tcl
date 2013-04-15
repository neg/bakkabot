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
    if {[lsearch $text "*bakka*"] >= 0} {
        # Print the first chicken without output (we know there will be more)
        set chick [get_chicken ""]

        # Separate bakka from other words
        set bakka [lsearch -all $text "*bakka*"]
        set text [lsearch -inline -all -not $text "*bakka*"]

        # More then 2 bakka's? Add them without chicken output
        for {set i 0} {$i < [expr [llength $bakka] - 1]} {incr i} {
            set chick [int::merge $chick [get_chicken ""]]
        }

        # Add the last chicken together with any potential non-bakka words
        if {$text == ""} {
            set chick [int::merge $chick [get_chicken]]
        } else {
            set chick [int::merge $chick [get_chicken $text]]
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
