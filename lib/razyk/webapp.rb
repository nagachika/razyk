
require "rack"
require "tempfile"
require "thread"
require "stringio"

require "razyk/graph"

module RazyK
  class WebApp
    def initialize
      reset
    end

    def reset
      @vm = nil
      @graph = 0
      @step = 0
      @thread = nil
      @port_in = StringIO.new
      @port_out = StringIO.new
      @queue = Queue.new
    end

    def template(name)
      File.join(File.dirname(File.expand_path(__FILE__)), "webapp", "templates", name)
    end

    def main_page(req)
      reset
      res = Rack::Response.new
      res.status = 200
      res.write File.read(template("main.html"))
      res
    end

    def not_found(req)
      res = Rack::Response.new
      res.status = 404
      res.write(<<-EOF)
        <html><head><title>#{req.path} is not found</title></head>
        <body>#{req.path} is not found</body></html>
      EOF
      res
    end

    def reduce_thread(vm)
      while q = @queue.pop
        q.push(vm.reduce)
      end
    end

    def set_program(req)
      res = Rack::Response.new
      begin
        tree = RazyK::Parser.parse(req.params["program"])
        if req.params["mode"] == "true"
          root = Pair.new(:OUTPUT, Pair.new(tree, :INPUT))
          @port_in = StringIO.new(req.params["stdin"] || "")
        else
          root = tree
        end
        # discard previous vm and thread
        if @thread
          @thread.kill
          @thread = nil
        end
        @vm = VM.new(root, @port_in, @port_out)
        # start Thread for reduction
        @thread = Thread.start do reduce_thread(@vm) end
      rescue
        res.status = 501
        puts $!.message, $@
        return res
      end
      res.header["Content-Type"] = "text/json"
      res.write('{"status":"success"}')
      res
    end

    def step(req)
      res = Rack::Response.new
      res.header["Content-Type"] = "text/plain"
      if @thread
        rep = Queue.new
        @queue.push(rep)
        if rep.pop
          @step += 1
        end
        res.write("OK")
      else
        res.write("enter program first")
      end
      res
    end

    def stdout(req)
      res = Rack::Response.new
      res.header["Content-Type"] = "text/plain"
      res.write(@port_out.string)
      res
    end

    def expression(req)
      res = Rack::Response.new
      res.header["Content-Type"] = "text/plain"
      if @vm
        res.write(@vm.tree.inspect)
      else
        res.write("enter program first")
      end
      res
    end

    def graph(req)
      res = Rack::Response.new
      if @vm
        res.header["Content-Type"] = "image/svg+xml"
        tmpfile = Tempfile.new("razyk_graph")
        RazyK::Graph.graph(@vm.tree, :style => :dag).output(:svg => tmpfile.path)
        res.write(tmpfile.read)
        tmpfile.unlink
      else
        res.header["Content-Type"] = "text/plain"
        res.write("enter program first")
      end
      res
    end

    def call(env)
      req = Rack::Request.new(env)
      case req.path
      when "/"
        res = main_page(req)
      when "/set_program"
        res = set_program(req)
      when "/step"
        res = step(req)
      when "/stdout"
        res = stdout(req)
      when "/expression"
        res = expression(req)
      when "/graph"
        res = graph(req)
      else
        res = not_found(req)
      end
      res.finish
    end
  end
end