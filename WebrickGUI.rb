#!/usr/bin/ruby
# coding: utf-8

require 'optparse'
require 'json'
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
			:connectIO => false,
			:data => nil,
		}

		parser = OptionParser.new
		parser.version = Version
		parser.banner = "Usage: WebrickGUI [options] command"
		parser.on('-p port', '--port', 'Port. Default is 10080.'){|v| opts[:port] = v}
		parser.on('-t path', '--template', 'Template file path.'){|v| opts[:template] = v}
		parser.on('-C', '--connectIO', 'Use this stdin and stdout. When set this option, command is not required.'){ opts[:connectIO] = true }
		parser.on('-c string',
				  'Render with json data "string" and server shutdown. When set this option, command is not required.'
				 ){|v|
					 opts[:data] = JSON.parse(v)
					 opts[:connectIO] = true
				 }

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
			$stderr.puts err
			exit
		end

		if (args.empty? || args[0].empty?) && !opts[:connectIO]
			$stderr.puts "Too few options."
			exit
		end

		command = args.concat( _ARGV )

		meta = {
			command: command,
			commandName: command[0],
			commandFull: command.join(' '),
			url: "http://localhost:#{opts[:port]}/",
			port: opts[:port],
			host: "localhost",
			template: opts[:template],
			connectIO: opts[:connectIO],
			data: opts[:data],
		}
		return meta
	end
	module_function :parseArg

	#
	# Open browser
	#
	def openBrowser(url)
		case RbConfig::CONFIG['host_os']
		when /mswin|mingw|cygwin/
			spawn("start #{url}"    , :out=>$stdout)
		when /darwin/
			spawn("open #{url}"     , :out=>$stdout)
		when /linux|bsd/
			spawn("xdg-open #{url}" , :out=>$stdout)
		end
	end
	module_function :openBrowser

	#
	# start WebrickGUI server
	#
	def start(meta = {})
		return nil if !meta.kind_of?(Hash)

		meta = {
			command: [],
			port: '10080',
			host: 'localhost',
			template: '',
			connectIO: true,
			data: nil,
		}.merge(meta)

		if meta[:command].is_a?(String)
			meta[:command] = [ meta[:command] ]
		elsif !meta[:command].kind_of?(Array)
			meta[:command] = []
		end

		meta[:commandName] ||= meta[:command][0] || ""
		meta[:commandFull] ||= meta[:command].join(' ') || meta[:commandName]
		meta[:url] ||= "http://#{meta[:host]}:#{meta[:port]}/"

		# run user command and start Webrick server
		WebrickGUI::Server.new(meta, input: meta[:input], output: meta[:output])
	end
	module_function :start

end



if __FILE__ == $0

	# parse command line arguments
	meta = WebrickGUI.parseArg(ARGV)

	# run user command and start Webrick server
	server = WebrickGUI::start( meta.merge({input: STDIN, output: STDOUT}) )

	# kill after 1 sec if '-c' option set.
	if !meta[:data].nil?
		sleep 1
		Process.kill(:INT, $$)
	end

	# wait
	server.webrick.server_thread.join

end
