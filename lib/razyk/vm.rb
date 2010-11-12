
require "enumerator"

if not(defined?(Enumerator)) and defined?(Enumerable::Enumerator)
  # for 1.8
  Enumerator = Enumerable::Enumerator
end

require "razyk/node"

module RazyK
  class VM
    class StackUnderflow < StandardError; end

    def initialize(tree, input=$stdin, output=$stdout, recursive=false)
      @root = Node.new(:root, [], [tree])
      @generator = nil
      @input = input
      @output = output
      @recursive = recursive
    end

    def tree
      @root.to[0]
    end

    # Pop num of Pairs nodes from stack.
    # Each Pair node is destroyed if it isn't referenced from other parent node
    # Return value is [<root Pair node for replace>, cdr1, cdr2, ...]
    def pop_pairs(stack, num)
      raise StackUnderflow if stack.size < num
      pairs = stack.pop(num)
      root = pairs.first
      root.cut_car if num <= 1
      cdrs = [ root.cut_cdr ]
      shared = false
      pairs.inject do |parent, child|
        parent.cut_car unless shared
        if child.from.size != 0
          shared = true
          cdrs.unshift(child.cdr)
        else
          cdrs.unshift(child.cut_cdr)
        end
        child
      end
      cdrs.unshift(root)
      cdrs
    end

    # replace old_root Pair with new_root Pair and push new_root to stack
    def replace_root(stack, old_root, new_root)
      old_root.replace(new_root)
      stack.push(new_root)
    end

    def evaluate(root, gen=nil)
      stack = [root]
      until step(stack, gen).nil?
        if gen
          gen.yield(self)
        end
      end
      if @recursive and stack.last.is_a?(Pair)
        evaluate(stack.last.cdr, gen)
      end
      nil
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
        root, x = pop_pairs(stack, 1)
        replace_root(stack, root, x)
      when :K
        # (K x y) -> x
        root, x, y = pop_pairs(stack, 2)
        replace_root(stack, root, x)
      when :S
        # (S x y z) -> ((x z) (y z))
        root, x, y, z = pop_pairs(stack, 3)
        new_pair = Pair.new(Pair.new(x, z), Pair.new(y, z))
        replace_root(stack, root, new_pair)
      when Integer
        # (<N> f x) -> x               (N == 0)
        #           -> (f (<N-1> f x)) (N > 0)
        root, f, x = pop_pairs(stack, 2)
        num = comb.label
        if num == 0
          replace_root(stack, root, x)
        else
          # shortcut
          if f.label == :INC and x.label.is_a?(Integer)
            replace_root(stack, root, Combinator.new(num + x.label))
          else
            dec_pair = Pair.new(Combinator.new(num-1), f)
            new_root = Pair.new(f, Pair.new(dec_pair, x))
            replace_root(stack, root, new_root)
          end
        end
      when :CONS
        # (CONS a d f) -> (f a d)
        root, a, d, f = pop_pairs(stack, 3)
        new_root = Pair.new(Pair.new(f, a), d)
        replace_root(stack, root, new_root)
      when :IN
        # (IN f) -> (CONS <CH> IN f) where <CH> is a byte from stdin
        ch = @input.read(1)
        if ch.nil?
          ch = 256
        else
          ch = ch.ord
        end
        new_root = Pair.new(Pair.new(:CONS, Combinator.new(ch)),
                            :DUMMY) # reuse :IN combinator
        comb.replace(new_root)
        new_root.cdr = comb
        stack.push(new_root)
      when :CAR
        # (CAR x) -> (x K)       (CAR = (Lx.x TRUE), TRUE = (Lxy.x) = K)
        root, x = pop_pairs(stack, 1)
        new_root = Pair.new(x, :K)  # K means TRUE
        replace_root(stack, root, new_root)
      when :CDR
        # (CDR x) -> (x (K I))  (CDR = (Lx.x FALSE), FALSE = (Lxy.y) = (K I)
        root, x = pop_pairs(stack, 1)
        new_root = Pair.new(x, Pair.new(:K, :I)) # (K I) means FALSE
        replace_root(stack, root, new_root)
      when :OUT
        # (OUTPUT f) -> ((PUTC ((CAR f) INC <0>) (OUTPUT (CDR f)))
        root, f = pop_pairs(stack, 1)
        new_root = Pair.new(
                     Pair.new(:PUTC,
                       Pair.new(Pair.new(Pair.new(:CAR, f), :INC), 0)),
                     Pair.new(comb, # reuse :OUT combinator
                              Pair.new(:CDR, f)))
        replace_root(stack, root, new_root)
      when :INC
        # (INC n) -> n+1 : increment church number
        raise StackUnderflow if stack.empty?
        evaluate(stack.last.cdr, gen)
        root, n = pop_pairs(stack, 1)
        unless n.label.is_a?(Integer)
          raise "argument of INC combinator is not a church number but #{n.inspect}"
        end
        replace_root(stack, root, Combinator.new(n.label + 1))
      when :PUTC
        # (PUTC x y) -> y : evaluate x and putchar it
        raise StackUnderflow if stack.size < 2
        x = stack.pop
        evaluate(x.cdr, gen)
        unless x.cdr.label.is_a?(Integer)
          raise "output is not church number"
        end
        num = x.cdr.label
        if num >= 256
          return nil
        end
        @output.write([num].pack("C"))
        root = stack.pop
        y = root.cut_cdr
        replace_root(stack, root, y)
      end
      true
    rescue StackUnderflow
      return nil
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
