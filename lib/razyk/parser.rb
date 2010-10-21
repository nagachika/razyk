
require "razyk/dag"

module RazyK

  module Parser
    # parse LazyK program string
    # TODO: only support "(S(KI))" style and "`s`ki" style.
    #       iota and jot styles are not supported yet.
    def parse(str)
      stack = []
      str.each_char do |ch|
        case ch
        when "S", "s"
          stack << Combinator.new(:S)
        when "K", "k"
          stack << Combinator.new(:K)
        when "I", "i"
          stack << Combinator.new(:I)
        when "(", "`"
          stack << :wedge
        end

        while stack.size > 1
          unless stack[-2,2].include?(:wedge)
            a, b = stack.pop(2)
            stack.pop if stack.last == :wedge
            stack.push(Pair.new(a,b))
          else
            break
          end
        end
      end
      raise "parse error" unless stack.size == 1
      stack[0]
    end
    module_function :parse
  end
end
