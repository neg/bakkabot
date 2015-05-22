namespace eval ascii {
    proc get_chicken {{text "BAKKA!!!"}} {
        lappend chick \
            "        " \
            "    \\   " \
            "    (o< $text" \
            " \\_//)  " \
            "  \_/_)  " \
            "   _|_  " \
            "        "

            return $chick
    }

    proc get_alien {{text "ALL HAIL!"}} {
        lappend alien \
            "   .--.   |V|" \
            "  /    \\ _| /" \
            "  q .. p \\ / " \
            "   \\--/  //  $text" \
            "  __||__//   " \
            " /.    _/    " \
            "// \\  /      "

        return $alien
    }

    proc build {text figure} {
        dict set triggers "!bakka" "chicken"
        dict set triggers "!hail" "alien"

        # Create trigger regexp and create list of matches
        set trigmatch [join [dict keys $triggers] "|"]
        set matches [lsearch -all -regexp $text $trigmatch]

        # If we are part of a chain append figure and recurse
        if {[llength $matches] != 0} {
            set art [get_$figure ""]
            # Figure out which next figure is and remove the trigger from text
            set index [lindex $matches 0]
            set newfigure [dict get $triggers [lindex $text $index]]
            set newtext [lreplace $text $index $index]
            return [misc::lmerge $art [build $newtext $newfigure]]
        }

        # Last figure in chain, if we still have text left use it as message,
        # if not use the default text
        if {$text != ""} {
            return [get_$figure $text]
        }
        return [get_$figure]
    }

    proc print {nick host hand chan text figure} {
        # Print figure(s) but skip lines only containing on spaces,
        # if for example we only print the chicken which have blank
        # rows for better alignment when combined with the alien
        foreach line [build $text $figure] {
            if {![string is space $line]} {
                putserv "PRIVMSG $chan : $line"
            }
        }
   }

   proc chicken {nick host hand chan text} {
       print $nick $host $hand $chan $text "chicken"
   }

   proc hail {nick host hand chan text} {
       print $nick $host $hand $chan $text "alien"
   }
}
