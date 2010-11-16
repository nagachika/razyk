class RazyK::Parser

token I K S
token SMALL_I
token BACKSLASH
token ASTAR
token LPAR RPAR
token ZERO ONE
token LITERAL STRING

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
          result = Combinator.new(:IOTA)
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
          @jot.reverse_each do |i|
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
        |   LITERAL
        {
          result = Combinator.new(val[0].to_sym)
        }
        | STRING
        {
          result = str2list(val[0])
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

require "razyk/node"

---- inner

def str2list(str)
  # (K 256) means End-of-stream. RazyK String adopt it as null terminator
  head = Pair.new(:K, 256)
  str.unpack("C*").reverse_each do |ch|
    head = Pair.new(Pair.new(:CONS, ch), head)
  end
  head
end

def scan
  # state : EXPR/IN_COMMENT/IN_LIRETAL/IN_STRING/IN_STRING_ESC
  state = :EXPR
  literal = []
  @lineno = 1
  @buf.each_char do |ch|
    @lineno += 1 if ch == "\n"
    case state
    when :IN_COMMENT
      state = :EXPR if ch == "\n"
      next
    when :IN_LITERAL
      if /[\w.-]/ =~ ch
        literal.push(ch)
        next
      else
        raise "empty literal at line.#{@lineno}" if literal.empty?
        name = literal.join
        literal.clear
        yield [:LITERAL, name]
        state = :EXPR
        # through down
      end
    when :IN_STRING
      if "\\" == ch
        state = :IN_STRING_ESC
      elsif '"' == ch
        yield [:STRING, literal.join]
        literal.clear
        state = :EXPR
      else
        literal.push(ch)
      end
      next
    when :IN_STRING_ESC
      case ch
      when "n"
        literal.push("\n")
      when "t"
        literal.push("\t")
      when "r"
        literal.push("\r")
      when "b"
        literal.push("\b")
      when "f"
        literal.push("\f")
      else
        literal.push(ch)
      end
      state = :IN_STRING
      next
    end

    tok = case ch
    when "#"
      state = :IN_COMMENT
      nil
    when "$"
      state = :IN_LITERAL
      nil
    when "\""
      state = :IN_STRING
      nil
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
    when "1"
      [:ONE, ch]
    end
    yield tok if tok
  end
  if state == :IN_LITERAL and not literal.empty?
    name = literal.join
    literal.clear
    yield [:LITERAL, name]
    state = :EXPR
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
