#!/usr/bin/ruby
# coding: utf-8

require 'json'

data = [
	{
		# short html render style.
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

looplimit = (ARGV[0] || 1000).to_i

looplimit.times do
	data.push STDIN.gets.chomp
	puts JSON.generate(data)
	STDOUT.flush
	STDERR.puts "stderr"	# stderr make no effect to result.
end

