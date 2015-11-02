# encoding: utf-8

require "test_helper"

require "razyk/node"

include RazyK

class RazyKNodeTest < Test::Unit::TestCase

  def test_combinator
    power_assert do
      Combinator.new(:l).label == :l
    end
    power_assert do
      Combinator.new(:name).to_s == "name"
    end
  end

  def test_pair_constructor
    a = Combinator.new :a
    b = Combinator.new :b
    pair = Pair.new(a, b)
    power_assert do
      pair.car == a
    end
    power_assert do
      pair.cdr == b
    end
    power_assert do
      pair.to_s == "(a b)"
    end
    power_assert do
      a.from == [pair]
    end
    power_assert do
      b.from == [pair]
    end
  end

  def test_pair_car_assign
    a = Combinator.new :a
    b = Combinator.new :b
    pair = Pair.new(a, b)
    c = Combinator.new :c
    pair.car = c

    power_assert do
      pair.car == c
    end
    power_assert do
      pair.cdr == b
    end
    power_assert do
      a.from == []
    end
    power_assert do
      c.from == [pair]
    end
    power_assert do
      b.from == [pair]
    end
    power_assert do
      pair.to_s == "(c b)"
    end
  end

  def test_pair_cdr_assign
    a = Combinator.new :a
    b = Combinator.new :b
    pair = Pair.new(a, b)
    c = Combinator.new :c
    pair.cdr = c

    power_assert do
      pair.car == a
    end
    power_assert do
      pair.cdr == c
    end
    power_assert do
      a.from == [pair]
    end
    power_assert do
      b.from.empty?
    end
    power_assert do
      c.from == [pair]
    end
    power_assert do
      pair.to_s == "(a c)"
    end
  end
end
