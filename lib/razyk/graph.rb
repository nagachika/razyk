require "razyk/node"

begin
  require "graphviz"
rescue LoadError
end

if defined?(GraphViz)
  module RazyK
    module Graph
      def create_node(gv, tree, ctx)
        i = ctx[:index]
        ctx[:index] = i + 1
        if tree.to.empty?
          gv.add_node("#{tree.label}#{i}", :label => tree.label.to_s)
        else
          gv.add_node("#{tree.label}#{i}", :shape => "point")
        end
      end
      module_function :create_node

      def graph_internal(gv, tree, node, ctx)
        tree.to.each do |n|
          cached = false
          if ctx[:cache] and ctx[:cache][n.object_id]
            gn = ctx[:cache][n.object_id]
            cached = true
          else
            gn = create_node(gv, n, ctx)
            ctx[:cache][n.object_id] = gn
          end
          if tree.car == n
            gv.add_edge(node, gn, :color => ctx[:car_arrow_color])
          else
            gv.add_edge(node, gn, :color => ctx[:cdr_arrow_color])
          end
          unless cached
            graph_internal(gv, n, gn, ctx)
          end
        end
      end
      module_function :graph_internal

      #
      # create GraphViz from combinator tree
      #
      def graph(tree, opt={})
        gv = GraphViz.new("CombinatorGraph")
        ctx = {
          :index => 0,
          :car_arrow_color => opt[:car_arrow_color] || :red,
          :cdr_arrow_color => opt[:cdr_arrow_color] || :black,
          :cache => (opt[:style] == :dag) ? {} : nil,
        }
        node = create_node(gv, tree, ctx)
        graph_internal(gv, tree, node, ctx)
        gv
      end
      module_function :graph

      def tree2svg(tree, file)
        graph(tree).output(:svg => file)
      end
    end
  end
end
