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
                    { result = Pair.new(Pair.new(val[1], Combinator.new(:S)),
                                        Combinator.new(:K)) }
                    |   ONE jot_expr
                    { retult = Combinator.new(:Jot) }
                    ;

jot_expr:   no_empty_jot_expr
        |   /* epsilon */
        {   result = Combinator.new(:I) }
        ;

end

---- header

require "razyk/dag"

---- inner

def scan
  in_comment = false
  @buf.each_byte do |ch|
    if ch == "\n"
      in_comment = false
      next
    end
    next if in_comment
    tok = case ch
    when "#"
      in_comment = true
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
  yyparse self, :scan
end

def self.parse(str, opt={})
  self.new.parse(str)
end
