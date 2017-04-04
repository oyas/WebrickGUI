#!/usr/bin/ruby
# coding: utf-8

require 'webrick'

THISDIR = File.expand_path(File.dirname(__FILE__))
ROOTDIR = './'
PORT = 10080

def server_start(port: PORT, rootdir: ROOTDIR, meta: {}, &block)
	server = WEBrick::HTTPServer.new({
		:DocumentRoot => rootdir,
		:Port => port,
	})

	server.mount_proc '/' do |req, res|
		case req.path
		when '/'
			filepath =
				case true
				when File.exist?("index.html.erb") then 'index.html.erb'
				when File.exist?("index.html")     then 'index.html'
				else THISDIR + '/index.html.erb'
				end
			res.content_type = "text/html"
			res.body = ERB.new( File.read(filepath) ).result(binding)
		when '/get'
			res.content_type = "application/json"
			res.body = block.call req, res
		when '/main.js'
			filepath = THISDIR + '/main.js'
			res.content_type = "text/javascript"
			res.body = File.read(filepath)
		else
			WEBrick::HTTPServlet::FileHandler.new(server, rootdir).service(req, res);
		end
	end

	Signal.trap(:INT){ server.shutdown }

	server.start

end
