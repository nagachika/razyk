module RazyK

  #
  # Combinator Expression is implemented as DAG (Directed Acyclic Graph)
  # There is two type of node
  #  Combinator - leaf node which has no child node.
  #               express elemental combinator.
  #  Pair       - non leaf node which always has 2 child node.
  #               express term of two combinators or terms
  #
  # ex) In pair expression like Lisp/Scheme
  # "``ski" => ( ( S . K ) . I )
  # "`s`ki" => ( S . ( K . I ) )
  #
  #  S, K, I are Combinator
  #  (S . K) is Pair
  #
  class Node
    def initialize(label, from=[], to=[])
      @label = label
      @from = []
      @to = []
      from.each do |f|
        self.class.connect(f, self)
      end
      to.each do |t|
        self.class.connect(self, t)
      end
    end
    attr_reader :label, :from, :to

    # create connectivity from a to b (a -> b)
    # TODO: circularity check
    def self.connect(a, b)
      a.to.push(b)
      b.from.push(a)
    end

    # destroy connectivity from a to b (a -x-> b)
    def self.disconnect(a, b)
      a.to.delete(b)
      b.from.delete(a)
    end

    # replace parent nodes' reference of self to new_node
    def replace(new_node)
      @from.dup.each do |f|
        f.replace_child(self, new_node)
      end
    end

    # replace child node from a to b
    def replace_child(a, b)
      self.class.disconnect(self, a)
      self.class.connect(self, b)
    end

    def integer?
      @label.is_a?(Integer) or (/\A\d+\z/ =~ @label)
    end
  end

  class Combinator < Node
    def initialize(comb)
      super(comb)
    end

    def to_s
      case l = @label.to_s
      when "S", "K", "I"
        l
      else
        "$" + l
      end
    end
    def inspect
      to_s
    end
  end

  #
  # Pair has only two child node (car and cdr).
  #  It represent term of combinators or terms.
  class Pair < Node
    def initialize(car, cdr)
      car = Combinator.new(car) unless car.is_a?(Node)
      cdr = Combinator.new(cdr) unless cdr.is_a?(Node)
      super(:Pair, [], [car, cdr])
      @car = car
      @cdr = cdr
    end
    attr_reader :car, :cdr

    def car=(n)
      replace_child(car, n)
    end

    def cdr=(n)
      replace_child(cdr, n)
    end

    def cut_car
      self.class.disconnect(self, car)
      car
    end

    def cut_cdr
      self.class.disconnect(self, cdr)
      cdr
    end

    def replace_child(a, b)
      super
      @car = b if @car == a
      @cdr = b if @cdr == a
      @to = [@car, @cdr]
    end

    def to_s
      "(#{@car} #{@cdr})"
    end
    def inspect
      to_s
    end
  end
end
