# encoding: utf-8

require_relative "spec_helper"

require "razyk/vm"
require "stringio"

include RazyK

describe VM do
  it "should reduce I combinator" do
    i = Combinator.new(:I)
    x = Combinator.new(:X)
    cons = Pair.new(i, x)
    vm = VM.new(cons)
    vm.tree.should == cons
    x.from.size.should == 1
    x.from[0].should == cons
    vm.reduce
    vm.tree.should == x
    x.from.size.should == 1
    x.from[0].should_not == cons
  end

  it "should reduce K combinator" do
    k = Combinator.new(:K)
    x = Combinator.new(:X)
    y = Combinator.new(:Y)
    cons1 = Pair.new(k, x)
    cons2 = Pair.new(cons1, y)
    vm = VM.new(cons2)
    vm.tree.should == cons2
    x.from.size.should == 1
    x.from[0].should == cons1
    vm.reduce
    vm.tree.should == x
    x.from.size.should == 1
    x.from[0].should_not == cons1
  end

  it "should reduce S combinator" do
    s = Combinator.new(:S)
    x = Combinator.new(:X)
    y = Combinator.new(:Y)
    z = Combinator.new(:Z)
    cons1 = Pair.new(s, x)
    cons2 = Pair.new(cons1, y)
    cons3 = Pair.new(cons2, z)
    vm = VM.new(cons3)
    vm.tree.should == cons3
    x.from.should == [ cons1 ]
    y.from.should == [ cons2 ]
    z.from.should == [ cons3 ]
    vm.reduce
    vm.tree.inspect.should == "((X Z) (Y Z))"
    x.from.size.should == 1
    x.from.should_not == [ cons1 ]
    y.from.size.should == 1
    y.from.should_not == [ cons2 ]
    z.from.size.should == 2
  end

  it "should reduce CONS and CAR combinator" do
    cons = Combinator.new(:CONS)
    a = Combinator.new(:A)
    b = Combinator.new(:B)
    list = Pair.new(Pair.new(cons, a), b)
    car = Combinator.new(:CAR)
    root = Pair.new(car, list)
    vm = VM.new(root)
    vm.evaluate(vm.tree)
    vm.tree.should == a
    a.from.size.should == 1
  end

  it "should reduce CONS and CDR combinator" do
    cons = Combinator.new(:CONS)
    a = Combinator.new(:A)
    b = Combinator.new(:B)
    list = Pair.new(Pair.new(cons, a), b)
    cdr = Combinator.new(:CDR)
    root = Pair.new(cdr, list)
    vm = VM.new(root)
    vm.evaluate(vm.tree)
    vm.tree.should == b
    b.from.size.should == 1
  end

  it "should reduce INPUT combinator (CAR)" do
    input = Combinator.new(:INPUT)
    car = Combinator.new(:CAR)
    root = Pair.new(car, input)
    buf = StringIO.new([100, 200].pack("C"))
    vm = VM.new(root, buf)
    vm.evaluate(vm.tree)
    vm.tree.should be_is_a(Combinator)
    vm.tree.label.should == :"<100>"
    buf.pos.should == 1
  end

  it "should reduce INPUT combinator (CDR)" do
    input = Combinator.new(:INPUT)
    cdr = Combinator.new(:CDR)
    root = Pair.new(cdr, input)
    buf = StringIO.new([100, 200].pack("C"))
    vm = VM.new(root, buf)
    vm.evaluate(vm.tree)
    vm.tree.should be_is_a(Combinator)
    vm.tree.label == :INPUT
    vm.tree.from.size.should == 1
    buf.pos.should == 1
  end

  it "should reduce PUTC combinator" do
    putc = Combinator.new(:PUTC)
    a = Combinator.new(:"<97>")
    x = Combinator.new(:X)
    decode = Pair.new(Pair.new(a, :INC), :"<0>")
    root = Pair.new(Pair.new(putc, decode), x)
    ibuf = StringIO.new("")
    obuf = StringIO.new("")
    vm = VM.new(root,ibuf, obuf)
    vm.evaluate(vm.tree)
    obuf.string.should == "a"
    vm.tree.should == x
    x.from.size.should == 1
  end
end
