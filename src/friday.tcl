namespace eval friday { namespace export * }

# Initialize upon sourcing
set friday::last [clock seconds]

# Register your friday callbacks here
lappend friday::callback friday::print_quote

proc friday::print_quote {nick chan} {
    global SCRIPT_PATH

    # Read the file every time, to allow us to add stuff without restarting
    set data [misc::parse_file "$SCRIPT_PATH/txt/friday"]
    putserv "PRIVMSG $chan :$nick: [misc::lrandom_element $data]"
}

proc friday::bind {nick chan} {
    # Check if it's Friday
    set day [clock format [clock seconds] -format "%w"]
    if {$day != 5} {
        return false
    }

    # Start by having a very low chance of printing directly after another
    # message, increasing over time to always printing after about one hour.
    set dt [expr [clock seconds] - $friday::last]
    set f [expr $dt / 3600.0]
    if { [expr rand()] >= [expr $f * $f] } {
        return false
    }

    [misc::lrandom_element $friday::callback] $nick $chan

    set friday::last [clock seconds]
    return true
}

