class RazyK::Parser

token I K S
token SMALL_I
token BACKSLASH
token ASTAR
token LPAR RPAR
token ZERO ONE

start program

rule

program :   ccexpr
        {
          result = val[0] || Combinator.new(:I)
        }
        ;

ccexpr  :   /* epsilon */
        {
          result = nil
        }
        |   ccexpr expr
        {
          if val[0].nil?
            result = val[1]
          else
            result = Pair.new(val[0], val[1])
          end
        }
        ;

expr    :   SMALL_I
        {
          result = Combinator.new(:I)
        }
        |   expr2
        ;

iotaexpr:   SMALL_I
        {
          result = Combinator.new(:Iota)
        }
        |   expr2
        ;

expr2   :   I
        {
          result = Combinator.new(:I)
        }
        |   K
        {
          result = Combinator.new(:K)
        }
        |   S
        {
          result = Combinator.new(:S)
        }
        |   no_empty_jot_expr
        {
          comb = Combinator.new(:I)
          @jot.each do |i|
            case i
            when 0
              comb = Pair.new(Pair.new(comb, :S), :K)
            when 1
              comb = Pair.new(:S, Pair.new(:K, comb))
            end
          end
          @jot.clear
          result = comb
        }
        |   BACKSLASH expr expr
        {
          result = Pair.new(val[1], val[2])
        }
        |   ASTAR iotaexpr iotaexpr
        {
          result = Pair.new(val[1], val[2])
        }
        |   LPAR ccexpr RPAR
        {
          result = val[1]
        }
        ;

no_empty_jot_expr   :   ZERO jot_expr
                    { @jot.push(0) }
                    |   ONE jot_expr
                    { @jot.push(1) }
                    ;

jot_expr:   no_empty_jot_expr
        |   /* epsilon */
        ;

end

---- header

require "razyk/dag"

---- inner

def scan
  in_comment = false
  @buf.each_char do |ch|
    if ch == "\n"
      in_comment = false
      next
    end
    next if in_comment
    tok = case ch
    when "#"
      in_comment = true
      next
    when "I"
      [:I, ch]
    when "i"
      [:SMALL_I, ch]
    when "K", "k"
      [:K, ch]
    when "S", "s"
      [:S, ch]
    when "`"
      [:BACKSLASH, ch]
    when "*"
      [:ASTAR, ch]
    when "("
      [:LPAR, ch]
    when ")"
      [:RPAR, ch]
    when "0"
      [:ZERO, ch]
    end
    yield tok if tok
  end
  yield [false, nil]
end

def parse(str, opt={})
  @buf = str
  @jot = []
  yyparse self, :scan
end

def self.parse(str, opt={})
  self.new.parse(str)
end
