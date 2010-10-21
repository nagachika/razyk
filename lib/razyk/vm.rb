
require "enumerator"

if not(defined?(Enumerator)) and defined?(Enumerable::Enumerator)
  # for 1.8
  Enumerator = Enumerable::Enumerator
end

require "razyk/dag"

module RazyK
  class VM
    def initialize(tree)
      @root = DAGNode.new(:root, [], [tree])
      @generator = nil
    end

    def tree
      @root.to[0]
    end

    def integer_combinator(num)
      Combinator.new(:"<#{num}>")
    end

    def evaluate(root, gen=nil)
      stack = [root]
      until step(stack).nil?
        if gen
          gen.yield(self)
        end
      end
    end

    def step(stack)
      return nil if stack.empty?
      while stack.last.is_a?(Pair)
        stack.push(stack.last.car)
      end
      comb = stack.pop
      case comb.label
      when :I
        return nil if stack.empty?
        x = stack.pop
        xcdr = x.cut_cdr
        x.replace(xcdr)
        stack.push(xcdr)
      when :K
        return nil if stack.size < 2
        y, x = stack.pop(2)
        x = x.cut_cdr
        y.replace(x)
        stack.push(x)
      when :S
        return nil if stack.size < 3
        z, y, x = stack.pop(3)
        # cut from parent
        root = z
        x = x.cut_cdr
        y = y.cut_cdr
        z = z.cut_cdr
        new_pair = Pair.new(Pair.new(x, z), Pair.new(y, z))
        root.replace(new_pair)
        stack.push(new_pair)
      when /<(\d+)>/
        return nil if stack.size < 2
        num = Regexp.last_match(1).to_i
        x, f = stack.pop(2)
        root = x
        x = x.cut_cdr
        f = f.cut_cdr
        if num
          root.replace(x)
          stack.push(x)
        else
          dec_pair = Pair.new(integer_combinator(num-1), f)
          new_pair = Pair.new(f, Pair.new(dec_pair, x))
          root.replace(new_pair)
          stack.push(new_pair)
        end
      when :CONS
        return nil if stack.size < 3
        f, d, a = stack.pop(3)
        root = f
        f.cut_car
        f = f.cut_cdr
        a.car = f
        root.replace(d)
        stack.push(d)
      when :IN
        return nil if stack.size < 1
        ch = $stdin.getc.ord
        new_root = Pair.new(Pair.new(Combinator.new(:CONS),
                                     integer_combinator(ch)),
                            comb) # reuse :IN combinator
        stack.last.car = new_root
        stack.push(new_root)
      end
      true
    end

    def reduce
      @generator ||= Enumerator.new{|e| evaluate(self.tree, e) }
      begin
        @generator.next
        self
      rescue StopIteration
        nil
      end
    end
  end
end
