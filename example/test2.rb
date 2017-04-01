#!/usr/bin/ruby
# coding: utf-8

require 'json'

data = [
	{
		"render" => "raw",
		"content" => {
			"a" => "b",
		},
	},
	{
		"render" => "html",
		"element" => "h2",
		"content" => "a<a>A</a>a",
	},
	"Hello, WebrickGUI.",
]

looplimit = (ARGV[0] || 1000).to_i

looplimit.times do
	data.push STDIN.gets.chomp
	puts JSON.generate(data)
	STDOUT.flush
	STDERR.puts "stderr"
end

