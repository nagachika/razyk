#!/usr/bin/env ruby

require "razyk"
require "optparse"

module RazyK
  class ApplicationError < RuntimeError; end

  class Application

    def initialize
      @program = nil
      @step = false
      @web_server = false
      @optparse = option_parser
    end

    def option_parser
      OptionParser.new do |opt|
        opt.banner = "Usage: razyk [options] [programfile]"
        opt.on("-e 'program'",
               "specify LazyK program string. Omit [programfile]") do |prog|
          @program = prog
        end
        opt.on("-s", "--step", "step execution. Dump combinator tree by each step") do
          @step = true
        end
        opt.on("--server [PORT]", "start web server") do |port|
          @port = Integer(port || 9292)
          @step = true
          @web_server = true
        end
        opt.on("--[no-]statistics", "dump statistics information at exit") do
          @statistics = { count: 0 }
        end
      end
    end
    private :option_parser

    def run_web_server
      require "razyk/webapp"
      app = RazyK::WebApp.new
      # This should work, but rack-1.2.1 fails. :app don't overwrite config.ru
      #Rack::Server.start(:app => app, :Port => @port)
      trap(:INT) do
        if Rack::Handler::WEBrick.respond_to?(:shutdown)
          Rack::Handler::WEBrick.shutdown
        else
          exit
        end
      end
      Rack::Handler::WEBrick.run(app, :Port => @port)
    end

    def run_interpreter(argv)
      if @program.nil?
        if argv.empty?
          raise RazyK::ApplicationError, "please specify LazyK program file"
        end
        filepath = argv.shift
        unless File.readable?(filepath)
          raise RazyK::ApplicationError, "#{filepath} not found or not readable"
        end
        @program = IO.read(filepath)
      end

      opts = {
        statistics: @statistics
      }

      if @step
        RazyK.run(@program, opts) do |vm|
          $stderr.puts vm.tree.inspect
        end
      else
        RazyK.run(@program, opts)
      end
    ensure
      if @statistics
        puts "Statistics Info:"
        puts "\t#{@statistics[:started_at]} - #{@statistics[:finished_at]} (#{@statistics[:finished_at]-@statistics[:started_at]} sec)"
        puts "\treduce count: #{@statistics[:count]}"
      end
    end

    def run(argv)
      @optparse.parse!(argv)

      if @web_server
        run_web_server
      else
        run_interpreter(argv)
      end
    rescue RazyK::ApplicationError
      $stderr.puts($!.message)
    end
  end
end
