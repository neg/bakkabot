#!/usr/bin/tclsh

# Log wrappers
set log_wrap {
    "puthelp"
    "putkick"
    "putlog"
    "putserv"
}
foreach name $log_wrap {
    puts "Registering log procedure \"$name\""
    proc $name {args} {
        set str {*}$args
        puts "[lindex [info level 0] 0]: $str"
    }
}

# Bind wrapper
proc bind {type none str do} {
    global binds
    dict set binds $str $do
    puts "Registering bind \"$str -> $do\""
}

# Source the bot
source main.tcl

# Test the chicken
bind::chicken myuser myhost myhand mychan mytest

# Read a test file and print it
set data [int::parse_file "txt/test"]
foreach line $data {
    puts "test: $line"
}

puts "Random index: [int::lrandom_index $data]"
puts "Random element: [int::lrandom_element $data]"
