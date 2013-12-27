namespace eval log { namespace export * }

proc log::debug {msg} {
    global PRINT_DEBUG
    if {!$PRINT_DEBUG} {
        return
    }

    if {[info level] > 1} {
        set caller [info level [expr [info level] - 1]]
        puts "debug $caller, $msg"
    } else {
        puts "debug, $msg"
    }
}

