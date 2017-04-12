#!/usr/bin/ruby
# coding: utf-8

require 'webrick'


module WebrickGUI

	class Webrick

		#
		# start webrick server thread
		#
		# param &block is callback function for user request.
		#
		def initialize(meta, &block)
			@server_thread = Thread.new do
				begin
					@server = server_start( meta, &block )
				rescue => e
					p e
				end
			end
		end

		attr_accessor :server, :server_thread

		#
		# for Webrick default param
		#
		THISDIR = File.expand_path(File.dirname(__FILE__))
		ROOTDIR = './'
		PORT = 10080

		#
		# start webrick server
		#
		def server_start(meta = {}, &block)
			port    = meta[:port]    || PORT
			rootdir = meta[:rootdir] || ROOTDIR
			data    = meta[:data]    || {}

			server = WEBrick::HTTPServer.new({
				:DocumentRoot => rootdir,
				:Port => port,
			})

			server.mount_proc '/' do |req, res|
				case req.path
				when '/'
					filepath =
						case true
						when File.exist?(meta[:template])  then meta[:template]
						when File.exist?("index.html.erb") then 'index.html.erb'
						when File.exist?("index.html")     then 'index.html'
						else THISDIR + '/index.html.erb'
						end
					res.content_type = "text/html"
					res.body = ERB.new( File.read(filepath) ).result(binding)
				when '/get'
					res.content_type = "application/json"
					res.body = block.call req
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

	end

end
