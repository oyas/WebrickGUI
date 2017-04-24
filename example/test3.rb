#!/usr/bin/ruby
# coding: utf-8

require 'json'

data = {
	content: [
		{
			"render" => "html",
			"element" => "h2",
			"content" => "TITLE",
		},
		"Hello, WebrickGUI.",
		{
			"render" => "html",
			"element" => "form",
			"attribute": {
				"action": "get"
			},
			"content" => [
				'<input id="a" type="text">',
				{
					"render" => "html",
					"element" => "button",
					"attribute" => {
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
	data[:content].push STDIN.gets.chomp
	puts JSON.generate(data)
	STDOUT.flush
	STDERR.puts "stderr"	# stderr make no effect to result.
end

