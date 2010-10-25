
require "enumerator"

if not(defined?(Enumerator)) and defined?(Enumerable::Enumerator)
  # for 1.8
  Enumerator = Enumerable::Enumerator
end

require "razyk/dag"

module RazyK
  class VM
    def initialize(tree, input=$stdin, output=$stdout)
      @root = DAGNode.new(:root, [], [tree])
      @generator = nil
      @input = input
      @output = output
    end

    def tree
      @root.to[0]
    end

    def integer_combinator(num)
      Combinator.new(:"<#{num}>")
    end

    def evaluate(root, gen=nil)
      stack = [root]
      until step(stack, gen).nil?
        if gen
          gen.yield(self)
        end
      end
    end

    def step(stack, gen=nil)
      return nil if stack.empty?
      while stack.last.is_a?(Pair)
        stack.push(stack.last.car)
      end
      comb = stack.pop
      case comb.label
      when :I
        # (I x) -> x
        return nil if stack.empty?
        x = stack.pop
        xcdr = x.cut_cdr
        x.replace(xcdr)
        stack.push(xcdr)
      when :K
        # (K x y) -> x
        return nil if stack.size < 2
        y, x = stack.pop(2)
        x = x.cut_cdr
        y.replace(x)
        stack.push(x)
      when :S
        # (S x y z) -> ((x z) (y z))
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
        # (<N> f x) -> x               (N == 0)
        #           -> (f (<N-1> f x)) (N > 0)
        return nil if stack.size < 2
        num = Regexp.last_match(1).to_i
        x, f = stack.pop(2)
        root = x
        x = x.cut_cdr
        f = f.cut_cdr
        if num == 0
          root.replace(x)
          stack.push(x)
        else
          dec_pair = Pair.new(integer_combinator(num-1), f)
          new_pair = Pair.new(f, Pair.new(dec_pair, x))
          root.replace(new_pair)
          stack.push(new_pair)
        end
      when :CONS
        # (CONS a d f) -> (f a d)
        return nil if stack.size < 3
        f, d, a = stack.pop(3)
        root = f
        f.cut_car
        f = f.cut_cdr
        a.car = f
        root.replace(d)
        stack.push(d)
      when :INPUT
        # (IN f) -> (CONS <CH> IN f) where <CH> is a byte from stdin
        return nil if stack.size < 1
        ch = @input.read(1)
        if ch.nil?
          ch = 256
        else
          ch = ch.ord
        end
        new_root = Pair.new(Pair.new(:CONS, integer_combinator(ch)),
                            comb) # reuse :INPUT combinator
        stack.last.car = new_root
        stack.push(new_root)
      when :CAR
        # (CAR x) -> (x K)       (CAR = (Lx.x TRUE), TRUE = (Lxy.x) = K)
        return nil if stack.size < 1
        x = stack.pop
        root = x
        x = x.cut_cdr
        new_root = Pair.new(x, :K)  # K means TRUE
        root.replace(new_root)
        stack.push(new_root)
      when :CDR
        # (CDR x) -> (x (K I))  (CDR = (Lx.x FALSE), FALSE = (Lxy.y) = (K I)
        return nil if stack.size < 1
        x = stack.pop
        root = x
        x = x.cut_cdr
        new_root = Pair.new(x, Pair.new(:K, :I)) # (K I) means FALSE
        root.replace(new_root)
        stack.push(new_root)
      when :OUTPUT
        # (OUTPUT f) -> ((PUTC ((CAR f) INC <0>) (OUTPUT (CDR f)))
        return nil if stack.size < 1
        f = stack.pop
        root = f
        f = f.cut_cdr
        root.cut_car
        new_root = Pair.new(
                     Pair.new(
                       Combinator.new(:PUTC),
                       Pair.new(
                         Pair.new(
                           Pair.new(Combinator.new(:CAR), f),
                           Combinator.new(:INC)),
                         integer_combinator(0))),
                     Pair.new(comb, # reuse :INPUT combinator
                              Pair.new(Combinator.new(:CDR), f)))
        root.replace(new_root)
        stack.push(new_root)
      when :INC
        # (INC n) -> n+1 : increment church number
        return nil if stack.size < 1
        root = stack.pop
        evaluate(root.cdr, gen)
        n = root.cut_cdr
        unless /<(\d+)>/ =~ n.label
          raise "argument of INC combinator is not a church number"
        end
        num = Regexp.last_match(1).to_i
        root.replace(integer_combinator(num+1))
      when :PUTC
        # (PUTC x y) -> y : evaluate x and putchar it
        return nil if stack.size < 2
        x = stack.pop
        evaluate(x.cdr, gen)
        unless x.cdr.label =~ /<(\d+)>/
          raise "output is not church number"
        end
        num = Regexp.last_match(1).to_i
        if num >= 256
          return nil
        end
        @output.write([num].pack("C"))
        root = stack.pop
        y = root.cut_cdr
        root.replace(y)
        stack.push(y)
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

    def run(&blk)
      if blk
        while reduce
          blk.call(self)
        end
      else
        evaluate(self.tree, nil)
      end
    end
  end
end
