
require "rack"
require "tempfile"
require "thread"
require "stringio"
require "json"

module RazyK
  class WebApp
    class InputStream
      def initialize(str="")
        @buf = str.b
        @chars = []
      end
      def getbyte
        if @buf
          ret = @buf.unpack("C")[0]
          @buf = @buf[1..-1]
          if ret
            @chars << ret
          end
          ret
        else
          nil
        end
      end
      def wrote
        @chars.pack("C*")
      end
      def remain
        @buf || ""
      end
    end

    def template(name)
      File.join(File.dirname(File.expand_path(__FILE__)), "webapp", "templates", name)
    end

    def main_page(req)
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

    def reduce(req)
      stdin_read = req.params["stdin_read"] || ""
      stdin_remain = req.params["stdin_remain"] || ""
      stdout = req.params["stdout"] || ""
      expression = req.params["expression"] || "(OUT (I IN))"
      recursive = (req.params["recursive"] == "true")
      port_in = InputStream.new(stdin_remain)
      port_out = StringIO.new("")

      memory = {}
      tree = RazyK::Parser.parse(expression, memory: memory)
      vm = VM.new(tree, port_in, port_out, recursive: recursive)
      vm.reduce
      res = Rack::Response.new
      res.header["Content-Type"] = "application/json"
      json_state = JSON::State.from_state(nil)
      json_state.max_nesting = 0
      res.write({
        expression: vm.tree.inspect,
        nodes: vm.tree.as_json,
        stdin_read: stdin_read + port_in.wrote,
        stdin_remain: port_in.remain,
        stdout: stdout + port_out.string,
      }.to_json(json_state))
      res
    end

    def call(env)
      req = Rack::Request.new(env)
      case req.path
      when "/"
        res = main_page(req)
      when "/reduce"
        res = reduce(req)
      else
        res = not_found(req)
      end
      res.finish
    end
  end
end
