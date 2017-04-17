#!/usr/bin/ruby
# coding: utf-8

require 'json'
require_relative "pipe.rb"
require_relative "webrick.rb"


module WebrickGUI

	#
	# WebrickGUI main server class
	#
	class Server

		def initialize(meta, input: nil, output: nil)
			@meta = meta

			# run user program
			@pipe = WebrickGUI::Pipe.new( @meta[:commandFull], connect_mode: @meta[:connectIO] ? 1 : 0, input:input, output:output )

			# short cut
			@in = @pipe.in
			@out = @pipe.out

			# start webrick server
			@webrick = WebrickGUI::Webrick.new(@meta){ |req|
				# return @meta[:data] if '-c' option set.
				next JSON.generate(@meta[:data]) if !@meta[:data].nil?

				# send user request to user program
				@pipe.send( req.query.to_json )
			}

			# auto open browser
			WebrickGUI.openBrowser( @meta[:url] )
		end

		attr_accessor :meta, :pipe, :webrick, :in, :out

	end

end
