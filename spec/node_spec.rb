# encoding: utf-8

require_relative "spec_helper"

require "razyk/node"

include RazyK

describe Combinator do
  it "should be created with label" do
    Combinator.new(:l).label.should == :l
  end

  it "#to_s return label string" do
    Combinator.new(:name).to_s.should == "name"
  end
end

describe Pair do
  it "should be created with two Combinator" do
    a = Combinator.new :a
    b = Combinator.new :b
    pair = Pair.new(a, b)
    pair.car.should == a
    pair.cdr.should == b
    pair.to_s.should == "(a b)"
    a.from.should == [pair]
    b.from.should == [pair]
  end

  it "#car= should replace car" do
    a = Combinator.new :a
    b = Combinator.new :b
    pair = Pair.new(a, b)
    c = Combinator.new :c
    pair.car = c
    pair.car.should == c
    pair.cdr.should == b
    a.from.should be_empty
    c.from.should == [pair]
    b.from.should == [pair]
    pair.to_s.should == "(c b)"
  end

  it "#cdr= should replace cdr" do
    a = Combinator.new :a
    b = Combinator.new :b
    pair = Pair.new(a, b)
    c = Combinator.new :c
    pair.cdr = c
    pair.car.should == a
    pair.cdr.should == c
    a.from.should == [pair]
    b.from.should be_empty
    c.from.should == [pair]
    pair.to_s.should == "(a c)"
  end
end
