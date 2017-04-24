#!/usr/bin/ruby
# coding: utf-8

#
# test program for ruby
#
# Run:
# 	$ ./ruby_example.rb
#
# WebrickGUI is executed in this script.
# And user do not need to write 'WebrickGUI.rb' on command line.
#

require 'json'
require_relative '../WebrickGUI.rb'


#
# Run WebrickGUI from your program.
#
server = WebrickGUI::start()
stdin = server.in
stdout = server.out

# able to put some messages to command line.
puts "started WebrickGUI."


data = {
	content: [
		{
			"h2" => {},
			"content" => "TITLE",
		},
		"Hello, WebrickGUI.",
		{
			"form": {
				"action": "get"
			},
			"content" => [
				'<input id="a" type="text">',
				{
					"button" => {
						"type" => "button",
						"onclick" => "WebrickGUI.send({input:$(\'#a\').val()});",
					},
					"content" => "send",
				},
			],
		},
	]
}

looplimit = (ARGV[0] || 1000).to_i

Signal.trap('INT'){
	puts 'trap INT'
	stdin.close
	stdout.close
}

looplimit.times do
	data[:content].push stdout.gets.chomp
	stdin.puts JSON.generate(data)
	stdin.flush
	puts "send data."
end

# wait for webrick response complete
sleep 1

# exiting
Process.kill(:INT, $$)

