
require "enumerator"

if not(defined?(Enumerator)) and defined?(Enumerable::Enumerator)
  # for 1.8
  Enumerator = Enumerable::Enumerator
end

require "razyk/node"

module RazyK
  class VM
    class StackUnderflow < StandardError; end

    def initialize(tree, input=$stdin, output=$stdout, recursive: false, statistics: nil)
      @root = Node.new(:root, [], [tree])
      @generator = nil
      @input = input
      @output = output
      @recursive = recursive
      @statistics = statistics
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

    def evaluate(root, &blk)
      stack = [root]
      until step(stack, &blk).nil?
        if blk
          blk.call(self)
        end
      end
      if @recursive and stack.last.is_a?(Pair)
        evaluate(stack.last.cdr, &blk)
      end
      nil
    end

    def step(stack, &blk)
      return nil if stack.empty?
      @statistics[:count] += 1 if @statistics
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
        new_root = Pair.new(Pair.new(x, z), Pair.new(y, z))
        replace_root(stack, root, new_root)
      when :IOTA
        #  (IOTA x) -> ((x S) K)
        root, x = pop_pairs(stack, 1)
        new_root = Pair.new(Pair.new(x, :S), :K)
        replace_root(stack, root, new_root)
      when :CONS
        # (CONS a d f) -> (f a d)
        root, a, d, f = pop_pairs(stack, 3)
        new_root = Pair.new(Pair.new(f, a), d)
        replace_root(stack, root, new_root)
      when :IN
        # (IN f) -> (S (S I (K <CH>)) (K IN)) where <CH> is a byte from stdin
        ch = @input.getbyte
        if ch.nil?
          ch = 256
        end
        new_root = Node.list(Combinator.new(ch), terminator: Combinator.new(:IN))
        comb.replace(new_root)
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
        evaluate(stack.last.cdr, &blk)
        root, n = pop_pairs(stack, 1)
        unless n.integer?
          begin
            msg = "argument of INC combinator is not a church number but #{n.inspect}"
          rescue
            msg = "argument of INC combinator is not a church number (too large combinator tree)"
          end
          raise msg
        end
        replace_root(stack, root, Combinator.new(n.integer + 1))
      when :PUTC
        # (PUTC x y) -> y : evaluate x and putchar it
        raise StackUnderflow if stack.size < 2
        x = stack.pop
        evaluate(x.cdr, &blk)
        unless x.cdr.integer?
          begin
            msg = "output is not church number but #{x.cdr.inspect}"
          rescue
            msg = "output is not church number (too large combinator tree)"
          end
          raise msg
        end
        num = x.cdr.integer
        if num >= 256
          return nil
        end
        @output.write([num].pack("C"))
        root = stack.pop
        y = root.cut_cdr
        replace_root(stack, root, y)
      else
        if comb.integer?
          # (<N> f x) -> x               (N == 0)
          #           -> (f (<N-1> f x)) (N > 0)
          root, f, x = pop_pairs(stack, 2)
          num = comb.integer
          if num == 0
            replace_root(stack, root, x)
          else
            # shortcut
            if f.label == :INC and x.integer?
              replace_root(stack, root, Combinator.new(num + x.integer))
            else
              dec_pair = Pair.new(Combinator.new(num-1), f)
              new_root = Pair.new(f, Pair.new(dec_pair, x))
              replace_root(stack, root, new_root)
            end
          end
        else # unknown combinator... treat as combinator without enough arguments
          raise StackUnderflow
        end
      end
      true
    rescue StackUnderflow
      return nil
    end

    def reduce
      evaluate(self.tree) {|vm| return vm }
      nil
    end

    def run(&blk)
      if @statistics
        @statistics[:started_at] = Time.now
      end
      evaluate(self.tree, &blk)
      if @statistics
        @statistics[:finished_at] = Time.now
      end
    end
  end
end
