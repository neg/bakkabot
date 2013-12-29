namespace eval log { namespace export * }

proc log::debug {msg} {
    global PRINT_DEBUG

    if {!$PRINT_DEBUG} {
        return
    }

    if {[info level] > 1} {
        set caller [lindex [info level [expr [info level] - 1]] 0]
        putlog "debug $caller, $msg"
    } else {
        putlog "debug, $msg"
    }
}

