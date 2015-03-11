namespace eval ascii {
    proc get_chicken {{text "BAKKA!!!"}} {
        lappend chick \
            "    \\   " \
            "    (o< $text" \
            " \\_//)  " \
            "  \_/_)  " \
            "   _|_  "

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

    proc print {nick host hand chan text figure trigger} {
       if {[lsearch -exact $text "!$trigger"] >= 0} {
           # Print the first artwork without output (we know there will be more)
           set art [get_$figure ""]

           # Separate trigger from other words
           set matches [lsearch -all $text "!$trigger"]
           set text [lsearch -inline -all -not $text "!$trigger"]

           # More then 2 matches? Add them without output
           for {set i 0} {$i < [expr [llength $matches] - 1]} {incr i} {
               set art [misc::lmerge $art [get_$figure ""]]
           }

           # Add the last artwork together with any potential non-trigger words
           if {$text == ""} {
               set art [misc::lmerge $art [get_$figure]]
           } else {
               set art [misc::lmerge $art [get_$figure $text]]
           }

       } elseif {$text == ""} {
           set art [get_$figure]
       } else {
           set art [get_$figure $text]
       }

       foreach line $art {
           putserv "PRIVMSG $chan : $line"
       }
    }

   proc chicken {nick host hand chan text} {
       print $nick $host $hand $chan $text "chicken" "bakka"
   }

   proc hail {nick host hand chan text} {
       print $nick $host $hand $chan $text "alien" "hail"
   }
}
