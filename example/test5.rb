#!/usr/bin/ruby
# coding: utf-8

#
# test program 5
#
# Run:
# 	$ ./test5.rb
#
# WebrickGUI is executed in this script.
# And user do not need to write 'WebrickGUI.rb' on command line.
#

require 'json'
require 'open3'


#
# Run WebrickGUI from your program. '-C' option is required.
#
stdin, stdout, stderr, wait_thr = Open3.popen3('../WebrickGUI.rb -C')

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

looplimit.times do
	data[:content].push stdout.gets.chomp
	stdin.puts JSON.generate(data)
	stdin.flush
	puts "send data."
end

# wait for webrick response complete
sleep 1

# exiting
stdin.close
stdout.close
stderr.close
Process.kill(:INT, wait_thr.pid)
