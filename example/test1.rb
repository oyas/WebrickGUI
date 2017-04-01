#!/usr/bin/ruby
# coding: utf-8

#
# test program 1
#
# Run:
# 	$ WebrickGUI.rb ./test1.rb
#
# then, open `http://localhost:10080/` on your browser.
#

require 'json'

data = [	# Array data rendered by 'blocks' renderer.
	{
		"render" => "html",
		"element" => "h2",
		"content" => "TITLE",
	},
	{
		"render" => "raw",
		"content" => {
			"a" => "b",
		},
	},
	"Hello, WebrickGUI.",	# String data rendered by 'raw' renderer.
]

# print JSON data.
puts JSON.generate(data)

