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
bind::chicken myuser myhost myhand mychan ""
bind::chicken myuser myhost myhand mychan "mytest"
puts "2 chickens"
bind::chicken myuser myhost myhand mychan "bakka"
puts "2 chickens"
bind::chicken myuser myhost myhand mychan "bakka word"
puts "3 chickens"
bind::chicken myuser myhost myhand mychan "bakka bakka word"
puts "3 chickens"
bind::chicken myuser myhost myhand mychan "bakka word bakka word2"
puts "4 chickens"
bind::chicken myuser myhost myhand mychan "bakka word bakka word2 bakka"
puts "5 chickens"
bind::chicken myuser myhost myhand mychan "bakka bakka bakka bakka"

# Read a test file and print it
set data [misc::parse_file "txt/test"]
foreach line $data {
    puts "test: $line"
}

puts "Random index: [misc::lrandom_index $data]"
puts "Random element: [misc::lrandom_element $data]"

bind::catch_all myuser myhost myhand mychan mytest
