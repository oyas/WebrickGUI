#!/usr/bin/ruby
# coding: utf-8

#
# test program, static page sample.
#
# Run:
# 	$ ./test.rb
#
# WebrickGUI is executed in this script.
# And user do not need to write 'WebrickGUI.rb' on command line.
#

require 'json'


data = {
	"a" => "static page sample."
}
puts JSON.generate(data)

#
# Run WebrickGUI for static page. '-c' option is required.
#
system("../../WebrickGUI.rb -c '" + JSON.generate(data) + "'")

