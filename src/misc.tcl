namespace eval misc { namespace export * }

# Return a random list index
proc misc::lrandom_index {mylist} {
    set len [llength $mylist]
    set hit [expr {int(rand()*$len)}]
    return $hit
}

# Return a random element in a list
proc misc::lrandom_element {mylist} {
    set len [llength $mylist]
    set hit [expr {int(rand()*$len)}]
    return [lindex $mylist $hit]
}

# Merge elements in lists of equal length
proc misc::lmerge {args} {
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

# Sort dict based on key
proc misc::dictkeysort {dict args} {
    set res {}
    foreach key [lsort {*}$args [dict keys $dict]] {
        dict set res $key [dict get $dict $key]
    }
    return $res
}

# Sort dict based on val
proc misc::dictvalsort {dict args} {
    set lst {}
    dict for {key val} $dict {
        lappend lst [list $key $val]
    }
    return [concat {*}[lsort -index 1 {*}$args $lst]]
}

# Parse a file, split it and remove empty lines
proc misc::parse_file {name} {
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
