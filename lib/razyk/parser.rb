#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.13
# from Racc grammer file "".
#

require 'racc/parser.rb'


require "razyk/node"

module RazyK
  class Parser < Racc::Parser

module_eval(<<'...end parser.y/module_eval...', 'parser.y', 114)

def str2list(str)
  Node.list(*str.unpack("C*"), memory: @memory)
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
  @memory = opt[:memory] || {}
  yyparse self, :scan
end

def self.parse(str, opt={})
  self.new.parse(str)
end
...end parser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
     7,     8,     9,     5,    11,    12,    13,    29,    16,    17,
    14,    15,     7,     8,     9,     5,    11,    12,    13,    18,
    16,    17,    14,    15,     7,     8,     9,    20,    11,    12,
    13,     3,    16,    17,    14,    15,     7,     8,     9,     5,
    11,    12,    13,   nil,    16,    17,    14,    15,     7,     8,
     9,    20,    11,    12,    13,   nil,    16,    17,    14,    15,
     7,     8,     9,     5,    11,    12,    13,   nil,    16,    17,
    14,    15,    16,    17,    16,    17 ]

racc_action_check = [
    23,    23,    23,    23,    23,    23,    23,    23,    23,    23,
    23,    23,     2,     2,     2,     2,     2,     2,     2,     3,
     2,     2,     2,     2,    22,    22,    22,    22,    22,    22,
    22,     1,    22,    22,    22,    22,    19,    19,    19,    19,
    19,    19,    19,   nil,    19,    19,    19,    19,    12,    12,
    12,    12,    12,    12,    12,   nil,    12,    12,    12,    12,
    11,    11,    11,    11,    11,    11,    11,   nil,    11,    11,
    11,    11,    17,    17,    16,    16 ]

racc_action_pointer = [
   nil,    31,    10,    19,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,    58,    46,   nil,   nil,   nil,    64,    62,   nil,    34,
   nil,   nil,    22,    -2,   nil,   nil,   nil,   nil,   nil,   nil ]

racc_action_default = [
    -2,   -21,    -1,   -21,    -3,    -4,    -5,    -8,    -9,   -10,
   -11,   -21,   -21,    -2,   -15,   -16,   -20,   -20,    30,   -21,
    -6,    -7,   -21,   -21,   -17,   -19,   -18,   -12,   -13,   -14 ]

racc_goto_table = [
     2,    21,    22,    25,    25,     1,    19,    24,    26,   nil,
   nil,    21,    28,    23,    27 ]

racc_goto_check = [
     2,     4,     5,     6,     6,     1,     3,     7,     7,   nil,
   nil,     4,     5,     2,     3 ]

racc_goto_pointer = [
   nil,     5,     0,    -5,   -11,   -10,   -13,    -9 ]

racc_goto_default = [
   nil,   nil,   nil,     4,     6,   nil,    10,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 15, :_reduce_1,
  0, 16, :_reduce_2,
  2, 16, :_reduce_3,
  1, 17, :_reduce_4,
  1, 17, :_reduce_none,
  1, 19, :_reduce_6,
  1, 19, :_reduce_none,
  1, 18, :_reduce_8,
  1, 18, :_reduce_9,
  1, 18, :_reduce_10,
  1, 18, :_reduce_11,
  3, 18, :_reduce_12,
  3, 18, :_reduce_13,
  3, 18, :_reduce_14,
  1, 18, :_reduce_15,
  1, 18, :_reduce_16,
  2, 20, :_reduce_17,
  2, 20, :_reduce_18,
  1, 21, :_reduce_none,
  0, 21, :_reduce_none ]

racc_reduce_n = 21

racc_shift_n = 30

racc_token_table = {
  false => 0,
  :error => 1,
  :I => 2,
  :K => 3,
  :S => 4,
  :SMALL_I => 5,
  :BACKSLASH => 6,
  :ASTAR => 7,
  :LPAR => 8,
  :RPAR => 9,
  :ZERO => 10,
  :ONE => 11,
  :LITERAL => 12,
  :STRING => 13 }

racc_nt_base = 14

racc_use_result_var = true

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "I",
  "K",
  "S",
  "SMALL_I",
  "BACKSLASH",
  "ASTAR",
  "LPAR",
  "RPAR",
  "ZERO",
  "ONE",
  "LITERAL",
  "STRING",
  "$start",
  "program",
  "ccexpr",
  "expr",
  "expr2",
  "iotaexpr",
  "no_empty_jot_expr",
  "jot_expr" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

module_eval(<<'.,.,', 'parser.y', 16)
  def _reduce_1(val, _values, result)
              result = val[0] || Combinator.get(:I, @memory)
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 22)
  def _reduce_2(val, _values, result)
              result = nil
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 26)
  def _reduce_3(val, _values, result)
              if val[0].nil?
            result = val[1]
          else
            result = Pair.cons(val[0], val[1], @memory)
          end
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 36)
  def _reduce_4(val, _values, result)
              result = Combinator.get(:I, @memory)
        
    result
  end
.,.,

# reduce 5 omitted

module_eval(<<'.,.,', 'parser.y', 43)
  def _reduce_6(val, _values, result)
              result = Combinator.get(:IOTA, @memory)
        
    result
  end
.,.,

# reduce 7 omitted

module_eval(<<'.,.,', 'parser.y', 50)
  def _reduce_8(val, _values, result)
              result = Combinator.get(:I, @memory)
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 54)
  def _reduce_9(val, _values, result)
              result = Combinator.get(:K, @memory)
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 58)
  def _reduce_10(val, _values, result)
              result = Combinator.get(:S, @memory)
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 62)
  def _reduce_11(val, _values, result)
              comb = Combinator.get(:I, @memory)
          @jot.reverse_each do |i|
            case i
            when 0
              comb = Pair.cons(Pair.cons(comb, :S, @memory), :K, @memory)
            when 1
              comb = Pair.cons(:S, Pair.cons(:K, comb, @memory), @memory)
            end
          end
          @jot.clear
          result = comb
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 76)
  def _reduce_12(val, _values, result)
              result = Pair.cons(val[1], val[2], @memory)
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 80)
  def _reduce_13(val, _values, result)
              result = Pair.cons(val[1], val[2], @memory)
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 84)
  def _reduce_14(val, _values, result)
              result = val[1]
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 88)
  def _reduce_15(val, _values, result)
              result = Combinator.get(val[0].to_sym, @memory)
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 92)
  def _reduce_16(val, _values, result)
              result = str2list(val[0])
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 97)
  def _reduce_17(val, _values, result)
     @jot.push(0) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 99)
  def _reduce_18(val, _values, result)
     @jot.push(1) 
    result
  end
.,.,

# reduce 19 omitted

# reduce 20 omitted

def _reduce_none(val, _values, result)
  val[0]
end

  end   # class Parser
  end   # module RazyK
