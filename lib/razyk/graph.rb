require "razyk/dag"

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
          gn = create_node(gv, n, ctx)
          gv.add_edge(node, gn)
          graph_internal(gv, n, gn, ctx)
        end
      end
      module_function :graph_internal

      #
      # create GraphViz from combinator tree
      #
      def graph(tree)
        gv = GraphViz.new("CombinatorGraph")
        ctx = { :index => 0 }
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
