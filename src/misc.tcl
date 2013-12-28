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

# Parse a text file, split it and remove empty lines
proc misc::parse_file {name} {
    if {![file exists $name]} {
        putlog "File \"$name\" does not exist"
        exit
    }

    set data [misc::slurp_file $name]

    set data [split $data "\n"]
    # Remove empty lines..
    set data [lsearch -inline -all -not -exact $data ""]
    return $data
}

# Slurp file if exists
proc misc::slurp_file {file} {
    set data {}
    if {[file exists $file]} {
        set fd [open $file r]
        set data [read $fd]
        close $fd
    }
    return $data
}

# Dump any data to file (while remembering that everything is strings..)
proc misc::dump_data {data file} {
    set fd [open $file w]
    puts -nonewline $fd $data
    close $fd
}
