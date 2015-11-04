require "razyk/vm"
require "razyk/parser"

ZERO = "KI"
ONE = "I"
TWO = "(S(S(KS)K)I)"
THREE = "((S(S(KS)K))(S(S(KS)K)I))"
FOUR = "(S(S(KS)K))((S(S(KS)K))(S(S(KS)K)I))"
FIVE = "(S(S(KS)(S(KK)(S(K(S(S(KS)K)I))I)))(S(K((S(S(KS)K))(S(S(KS)K)I)))I))"

def mul(comb, n)
  "(S(K#{n})(S(K#{comb})I))"
end

def destruct(n)
  return ZERO if n == 0
  return ONE if n == 1
  return TWO if n == 2
  return THREE if n == 3
  return FOUR if n == 4
  return FIVE if n == 5
  comb = ONE
  while n % 2 == 0
    n /= 2
    comb = mul(comb, TWO)
  end
  while n % 3 == 0
    n /= 3
    comb = mul(comb, THREE)
  end
  while n % 5 == 0
    n /= 5
    comb = mul(comb, FIVE)
  end
  if n == 1
    return comb
  else
    return mul(comb, "((S(S(KS)K))#{destruct(n-1)})")
  end
end

def cons(a, b)
  "(S(SI(K(#{a})))(K(#{b})))"
end

def ary2list(ary)
  ([256] + ary.reverse).inject("I"){ |cdr, car|
    cons(destruct(car), cdr)
  }
end

def evaluate_church(comb)
  s = {count: 0}
  RazyK::VM.new(RazyK::Parser.parse("#{comb} $f $x"), statistics: s, recursive: true).run{|b| p b.tree }
  s[:count]
end

def evaluate_list(comb)
  s = {count: 0}
  RazyK::VM.new(RazyK::Parser.parse("$OUT ((K #{comb}) $IN)"), statistics: s, recursive: false).run
  s[:count]
end
