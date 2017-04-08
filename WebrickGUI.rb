#!/usr/bin/ruby
# coding: utf-8

require 'optparse'
require_relative "server.rb"


module WebrickGUI

	Version = '0.0.1-dev'

	#
	# parse command line arguments
	#
	def parseArg(_ARGV)
		opts = {
			:port => 10080,
			:template => '',
		}

		parser = OptionParser.new
		parser.version = Version
		parser.banner = "Usage: WebrickGUI [options] command"
		parser.on('-p port', '--port', 'Port. Default is 10080.') {|v| opts[:port] = v}
		parser.on('-t path', '--template', 'Template file path.') {|v| opts[:template] = v}

		args = []
		_ARGV2 = []
		err = ""
		while !_ARGV.empty? do
			_ARGV2.push( _ARGV.shift )
			err = ""
			begin
				args = parser.parse(_ARGV2)
			rescue => e
				err = e.message
			end
			break if !args.empty?
		end

		if !err.empty?
			puts err
			exit
		end

		if args.empty? || args[0].empty?
			puts "Too few options."
			exit
		end

		command = args.concat( _ARGV )

		@meta = {
			command: command,
			commandName: command[0],
			commandFull: command.join(' '),
			url: "http://localhost:#{opts[:port]}/",
			port: opts[:port],
			host: "localhost",
			template: opts[:template],
		}
		return @meta
	end
	module_function :parseArg

	#
	# Open browser
	#
	def openBrowser(url)
		case RbConfig::CONFIG['host_os']
		when /mswin|mingw|cygwin/
			spawn "start #{url}"
		when /darwin/
			spawn "open #{url}"
		when /linux|bsd/
			spawn "xdg-open #{url}"
		end
	end
	module_function :openBrowser

end



if __FILE__ == $0

	# parse command line arguments
	meta = WebrickGUI.parseArg(ARGV)

	# run user command and start Webrick server
	server = WebrickGUI::Server.new(meta)

	# wait
	server.webrick.server_thread.join

end
