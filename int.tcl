namespace eval int { namespace export * }

proc int::debug {msg} {
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

# Return a random list index
proc int::lrandom_index {mylist} {
    set len [llength $mylist]
    set hit [expr {int(rand()*$len)}]
    return $hit
}

# Return a random element in a list
proc int::lrandom_element {mylist} {
    set len [llength $mylist]
    set hit [expr {int(rand()*$len)}]
    return [lindex $mylist $hit]
}

# Parse a file, split it and remove empty lines
proc int::parse_file {name} {
    # Do some basic sanity checking on the filename
    if {![regexp {^txt/[a-z.]+$} $name]} {
        putlog "Filename \"$name\" failed sanity check"
        exit
    }

    set fp [open $name r]
    set data [read $fp]
    close $fp

    set data [split $data "\n"]
    # Remove empty lines..
    set data [lsearch -inline -all -not -exact $data ""]
    return $data
}

# Merge elements in lists of equal length
proc int::merge {args} {
    set base [lindex $args 0]
    foreach list [lrange $args 1 end] {
        set i 0
        foreach elem $list {
            set base [lreplace $base $i $i "[lindex $base $i] $elem"]
            incr i
        }
    }
    return $base
}
