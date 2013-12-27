namespace eval chicken { namespace export * }

proc chicken::get {{text "BAKKA!!!"}} {
    lappend chick \
        "    \\   " \
        "    (o< $text" \
        " \\_//)  " \
        "  \_/_)  " \
        "   _|_  "

        return $chick
}

proc chicken::bind {nick host hand chan text} {
    if {[lsearch $text "*bakka*"] >= 0} {
        # Print the first chicken without output (we know there will be more)
        set chick [chicken::get ""]

        # Separate bakka from other words
        set bakka [lsearch -all $text "bakka"]
        set text [lsearch -inline -all -not $text "bakka"]

        # More then 2 bakka's? Add them without chicken output
        for {set i 0} {$i < [expr [llength $bakka] - 1]} {incr i} {
            set chick [misc::lmerge $chick [chicken::get ""]]
        }

        # Add the last chicken together with any potential non-bakka words
        if {$text == ""} {
            set chick [misc::lmerge $chick [chicken::get]]
        } else {
            set chick [misc::lmerge $chick [chicken::get $text]]
        }

    } elseif {$text == ""} {
        set chick [chicken::get]
    } else {
        set chick [chicken::get $text]
    }

    foreach line $chick {
        putserv "PRIVMSG $chan : $line"
    }
}
