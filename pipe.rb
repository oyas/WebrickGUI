#!/usr/bin/ruby
# coding: utf-8

require 'open3'


module WebrickGUI

	class Pipe

		InputQueue  = Queue.new
		OutputQueue = Queue.new

		def initialize(command)
			@command = command

			#
			# run user program
			#
			@stdin, @stdout, @stderr, @wait_thread = Open3.popen3( @command )

			#
			# start IO threads
			#
			@output_thread = start_output_thread
			@input_thread = start_input_thread
			@err_thread = start_err_thread
			@checkalive_thread = start_checkalive_thread
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
				@stdin, @stdout, @stderr, @wait_thread = Open3.popen3( @command )
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

	end
end