#!/usr/bin/ruby
# coding: utf-8

require 'optparse'
require 'open3'
require 'thread'
require 'json'

require_relative "server.rb"

OPTS = {
	:p => 10080,
}


#
# parse arg
#
def parseArg
	parser = OptionParser.new
	parser.version = '0.0.1-dev'
	parser.banner = "Usage: WebrickGUI [options] command"
	parser.on('-p port', '--port:10080') {|v| OPTS[:p] = v}

	args = []
	_ARGV2 = []
	err = ""
	while !ARGV.empty? do
		_ARGV2.push( ARGV.shift )
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

	command = args.concat( ARGV )

	return {
		command: command,
		commandName: command[0],
		commandFull: command.join(' '),
	}
end

# meta data
@meta = parseArg()



#
# run user program
#
@stdin, @stdout, @stderr, @wait_thread = Open3.popen3( @meta[:commandFull] )

InputQueue  = Queue.new
OutputQueue = Queue.new


def start_output_thread
	Thread.new do
		puts "start_output_thread"
		begin
			# get data from user program
			while data = @stdout.gets
				puts "output: " + data
				OutputQueue.push data
			end
		rescue => e
			p e
		end
	end
end

def start_input_thread
	Thread.new do
		puts "start_input_thread"
		begin
			# puts data to user program
			loop do
				input_data = InputQueue.pop
				command_alive?(true)
				@stdin.puts input_data
			end
		rescue => e
			p e
		end
	end
end

def start_err_thread
	Thread.new do
		puts "start_err_thread"
		begin
			while data = @stderr.gets
				STDERR.puts data
			end
		rescue => e
			p e
		end
	end
end

def start_checkalive_thread
	Thread.new do
		puts "start_checkalive_thread"
		begin
			loop do
				alive = ['run', 'sleep'].include?( @wait_thread.status )
				if !alive
					OutputQueue.push '"(dead)"'
					break
				end
				Thread.pass
			end
		rescue => e
			p e
		end
	end
end

def command_alive?(restart = false)
	result = ['run', 'sleep'].include?( @wait_thread.status )
	#puts "command_alive? : " + result.to_s
	if !result && restart
		p @wait_thread.status
		puts "program restart"
		@stdin.close
		@stdout.close
		@stderr.close
		@output_thread.join
		@err_thread.join
		@checkalive_thread.join
		@stdin, @stdout, @stderr, @wait_thread = Open3.popen3( @meta[:commandFull] )
		@output_thread = start_output_thread
		@err_thread = start_err_thread
		@checkalive_thread = start_checkalive_thread
	end
	result
end


#
# start IO threads
#
@output_thread = start_output_thread
@input_thread = start_input_thread
@err_thread = start_err_thread
@checkalive_thread = start_checkalive_thread


#
# start webrick
#
@server_thread = Thread.new do
	begin
		@server = server_start( port: OPTS[:p], meta: @meta ){ |req, res|
			OutputQueue.clear
			InputQueue.push req.query.to_json
			OutputQueue.pop
		}
	rescue => e
		p e
	end
end

@server_thread.join

