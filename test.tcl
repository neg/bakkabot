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
chicken::bind myuser myhost myhand mychan ""
chicken::bind myuser myhost myhand mychan "mytest"
puts "2 chickens"
chicken::bind myuser myhost myhand mychan "bakka"
puts "2 chickens"
chicken::bind myuser myhost myhand mychan "bakka word"
puts "3 chickens"
chicken::bind myuser myhost myhand mychan "bakka bakka word"
puts "3 chickens"
chicken::bind myuser myhost myhand mychan "bakka word bakka word2"
puts "4 chickens"
chicken::bind myuser myhost myhand mychan "bakka word bakka word2 bakka"
puts "5 chickens"
chicken::bind myuser myhost myhand mychan "bakka bakka bakka bakka"

# Test dict sorting
set mydict [dict create a 1 b 2 c 3]
puts "Dict reverse sorted by keys: [misc::dictkeysort $mydict -decreasing]"
puts "Dict reverse sorted by values: [misc::dictvalsort $mydict -integer -decreasing]"


# Read a test file and print it
set data [misc::parse_file "txt/test"]
foreach line $data {
    puts "test: $line"
}

puts "Random index: [misc::lrandom_index $data]"
puts "Random element: [misc::lrandom_element $data]"

# Dump and slurp data-structures
set data {}
dict lappend data a "String"
dict lappend data a "Another string"
dict lappend data b "String"

misc::dump_data $data "data.dump"
set mirror [misc::slurp_file "data.dump"]
if {$data == $mirror} {
    puts "Slurp-dump match"
} else {
    puts "fail, slurp-dump mismatch"
}

catch_all myuser myhost myhand mychan mytest
