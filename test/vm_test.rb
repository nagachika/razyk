# encoding: utf-8

require "test_helper"

require "razyk/vm"
require "stringio"

include RazyK

class RazyKVMTest < Test::Unit::TestCase
  def test_reduce_I
    i = Combinator.new(:I)
    x = Combinator.new(:X)
    cons = Pair.new(i, x)
    vm = VM.new(cons)
    power_assert { vm.tree == cons }
    power_assert { x.from.size == 1 }
    power_assert { x.from[0] == cons }
    vm.reduce
    power_assert { vm.tree == x }
    power_assert { x.from.size == 1 }
    power_assert { x.from[0] != cons }
  end

  def test_reduce_K
    k = Combinator.new(:K)
    x = Combinator.new(:X)
    y = Combinator.new(:Y)
    cons1 = Pair.new(k, x)
    cons2 = Pair.new(cons1, y)
    vm = VM.new(cons2)
    power_assert { vm.tree == cons2 }
    power_assert { x.from.size == 1 }
    power_assert { x.from[0] == cons1 }
    vm.reduce
    power_assert { vm.tree == x }
    power_assert { x.from.size == 1 }
    power_assert { x.from[0] != cons1 }
  end

  def test_reduce_S
    s = Combinator.new(:S)
    x = Combinator.new(:X)
    y = Combinator.new(:Y)
    z = Combinator.new(:Z)
    cons1 = Pair.new(s, x)
    cons2 = Pair.new(cons1, y)
    cons3 = Pair.new(cons2, z)
    vm = VM.new(cons3)
    power_assert { vm.tree == cons3 }
    power_assert { x.from == [ cons1 ] }
    power_assert { y.from == [ cons2 ] }
    power_assert { z.from == [ cons3 ] }
    vm.reduce
    power_assert { vm.tree.inspect == "(($X $Z) ($Y $Z))" }
    power_assert { x.from.size == 1 }
    power_assert { x.from != [ cons1 ] }
    power_assert { y.from.size == 1 }
    power_assert { y.from != [ cons2 ] }
    power_assert { z.from.size == 2 }
  end

  def test_reduce_CONS_CAR
    cons = Combinator.new(:CONS)
    a = Combinator.new(:A)
    b = Combinator.new(:B)
    list = Pair.new(Pair.new(cons, a), b)
    car = Combinator.new(:CAR)
    root = Pair.new(car, list)
    vm = VM.new(root)
    vm.evaluate(vm.tree)
    power_assert { vm.tree == a }
    power_assert { a.from.size == 1 }
  end

  def test_reduce_CONS_CDR
    cons = Combinator.new(:CONS)
    a = Combinator.new(:A)
    b = Combinator.new(:B)
    list = Pair.new(Pair.new(cons, a), b)
    cdr = Combinator.new(:CDR)
    root = Pair.new(cdr, list)
    vm = VM.new(root)
    vm.evaluate(vm.tree)
    power_assert { vm.tree == b }
    power_assert { b.from.size == 1 }
  end

  def test_reduce_CAR_IN
    input = Combinator.new(:IN)
    car = Combinator.new(:CAR)
    root = Pair.new(car, input)
    buf = StringIO.new([100, 200].pack("C"))
    vm = VM.new(root, buf)
    vm.evaluate(vm.tree)
    power_assert { vm.tree.is_a?(Combinator) }
    power_assert { vm.tree.label == 100 }
    power_assert { buf.pos == 1 }
  end

  def test_reduce_CDR_IN
    input = Combinator.new(:IN)
    cdr = Combinator.new(:CDR)
    root = Pair.new(cdr, input)
    buf = StringIO.new([100, 200].pack("C*"))
    vm = VM.new(root, buf)
    vm.evaluate(vm.tree)
    power_assert { vm.tree.is_a?(Pair) }
    power_assert { vm.tree.cdr.label == :IN }
    power_assert { vm.tree.from.size == 1 }
    power_assert { buf.pos == 2 }
  end

  def test_reduce_PUTC
    putc = Combinator.new(:PUTC)
    a = Combinator.new(97)
    x = Combinator.new(:X)
    decode = Pair.new(Pair.new(a, :INC), 0)
    root = Pair.new(Pair.new(putc, decode), x)
    ibuf = StringIO.new("")
    obuf = StringIO.new("")
    vm = VM.new(root,ibuf, obuf)
    vm.evaluate(vm.tree)
    power_assert { obuf.string == "a" }
    power_assert { vm.tree == x }
    power_assert { x.from.size == 1 }
  end
end
