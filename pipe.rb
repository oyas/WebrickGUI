#!/usr/bin/ruby
# coding: utf-8

require 'open3'


module WebrickGUI

	class Pipe

		InputQueue  = Queue.new
		OutputQueue = Queue.new

		attr_accessor :in, :out

		# default is output: STDOUT, input: STDIN
		def initialize(command, connect_mode: 0, input: nil, output: nil)
			@command = command
			@connect_mode = connect_mode

			# パイプ生成
			@in = @out = nil
			input, @in   = IO.pipe if input.nil?
			@out, output = IO.pipe if output.nil?

			@default_IO = {
				in: output,
				out: input,
			}

			#
			# run user program
			#
			open_pipe

			#
			# start IO threads
			#
			@output_thread = start_output_thread
			@input_thread = start_input_thread
			@err_thread = start_err_thread
			@checkalive_thread = start_checkalive_thread
		end

		def open_pipe
			case @connect_mode
			when 1
				# redirect STDIN and STDOUT
				@stdin  = @default_IO[:in]
				@stdout = @default_IO[:out]
				@stderr = open(File::NULL, 'r')
				@wait_thread = DummyThread.new   # dummy like a thread
				if @stdin === STDOUT
					$stdout = open(File::NULL, 'w')
				end
			else
				# default mode: open pipe of command
				@stdin, @stdout, @stderr, @wait_thread = Open3.popen3( @command )
			end
		end

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
						@stdin.flush
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
						sleep 0.1
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
				open_pipe
				@output_thread = start_output_thread
				@err_thread = start_err_thread
				@checkalive_thread = start_checkalive_thread
			end
			result
		end

		def send(data)
			OutputQueue.clear
			InputQueue.push data
			OutputQueue.pop
		end

		# Dummy thread class. It works like a wait_thread.
		class DummyThread
			def status; 'run'; end
		end

	end
end
