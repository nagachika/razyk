#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.6
# from Racc grammer file "".
#

require 'racc/parser.rb'


require "razyk/node"

module RazyK
  class Parser < Racc::Parser

module_eval(<<'...end parser.y/module_eval...', 'parser.y', 110)

def scan
  in_comment = false
  in_literal = false
  literal = []
  @lineno = 1
  @buf.each_char do |ch|
    @lineno += 1 if ch == "\n"
    if in_comment
      in_comment = false if ch == "\n"
      next
    end
    if in_literal
      if /[\w.-]/ =~ ch
        literal.push(ch)
        next
      else
        raise "empty literal at line.#{@lineno}" if literal.empty?
        name = literal.join
        literal.clear
        yield [:LITERAL, name]
        in_literal = false
        # down through
      end
    end
    tok = case ch
    when "#"
      in_comment = true
      nil
    when "$"
      in_literal = true
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
  if in_literal and not literal.empty?
    name = literal.join
    literal.clear
    yield [:LITERAL, name]
    in_literal = false
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
...end parser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
     7,     8,     9,     5,    11,    12,    13,    28,    15,    16,
    14,     7,     8,     9,     5,    11,    12,    13,    17,    15,
    16,    14,     7,     8,     9,    19,    11,    12,    13,     3,
    15,    16,    14,     7,     8,     9,     5,    11,    12,    13,
   nil,    15,    16,    14,     7,     8,     9,    19,    11,    12,
    13,   nil,    15,    16,    14,     7,     8,     9,     5,    11,
    12,    13,   nil,    15,    16,    14,    15,    16,    15,    16 ]

racc_action_check = [
    22,    22,    22,    22,    22,    22,    22,    22,    22,    22,
    22,     2,     2,     2,     2,     2,     2,     2,     3,     2,
     2,     2,    21,    21,    21,    21,    21,    21,    21,     1,
    21,    21,    21,    18,    18,    18,    18,    18,    18,    18,
   nil,    18,    18,    18,    12,    12,    12,    12,    12,    12,
    12,   nil,    12,    12,    12,    11,    11,    11,    11,    11,
    11,    11,   nil,    11,    11,    11,    16,    16,    15,    15 ]

racc_action_pointer = [
   nil,    29,     9,    18,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,    53,    42,   nil,   nil,    58,    56,   nil,    31,   nil,
   nil,    20,    -2,   nil,   nil,   nil,   nil,   nil,   nil ]

racc_action_default = [
    -2,   -20,    -1,   -20,    -3,    -4,    -5,    -8,    -9,   -10,
   -11,   -20,   -20,    -2,   -15,   -19,   -19,    29,   -20,    -6,
    -7,   -20,   -20,   -16,   -18,   -17,   -12,   -13,   -14 ]

racc_goto_table = [
     2,    20,    21,    24,    24,    18,    23,    25,     1,   nil,
    20,    27,    26,    22 ]

racc_goto_check = [
     2,     4,     5,     6,     6,     3,     7,     7,     1,   nil,
     4,     5,     3,     2 ]

racc_goto_pointer = [
   nil,     8,     0,    -6,   -11,   -10,   -12,    -9 ]

racc_goto_default = [
   nil,   nil,   nil,     4,     6,   nil,    10,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 14, :_reduce_1,
  0, 15, :_reduce_2,
  2, 15, :_reduce_3,
  1, 16, :_reduce_4,
  1, 16, :_reduce_none,
  1, 18, :_reduce_6,
  1, 18, :_reduce_none,
  1, 17, :_reduce_8,
  1, 17, :_reduce_9,
  1, 17, :_reduce_10,
  1, 17, :_reduce_11,
  3, 17, :_reduce_12,
  3, 17, :_reduce_13,
  3, 17, :_reduce_14,
  1, 17, :_reduce_15,
  2, 19, :_reduce_16,
  2, 19, :_reduce_17,
  1, 20, :_reduce_none,
  0, 20, :_reduce_none ]

racc_reduce_n = 20

racc_shift_n = 29

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
  :LITERAL => 12 }

racc_nt_base = 13

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
              result = val[0] || Combinator.new(:I)
        
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
            result = Pair.new(val[0], val[1])
          end
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 36)
  def _reduce_4(val, _values, result)
              result = Combinator.new(:I)
        
    result
  end
.,.,

# reduce 5 omitted

module_eval(<<'.,.,', 'parser.y', 43)
  def _reduce_6(val, _values, result)
              result = Combinator.new(:IOTA)
        
    result
  end
.,.,

# reduce 7 omitted

module_eval(<<'.,.,', 'parser.y', 50)
  def _reduce_8(val, _values, result)
              result = Combinator.new(:I)
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 54)
  def _reduce_9(val, _values, result)
              result = Combinator.new(:K)
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 58)
  def _reduce_10(val, _values, result)
              result = Combinator.new(:S)
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 62)
  def _reduce_11(val, _values, result)
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
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 76)
  def _reduce_12(val, _values, result)
              result = Pair.new(val[1], val[2])
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 80)
  def _reduce_13(val, _values, result)
              result = Pair.new(val[1], val[2])
        
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
              result = Combinator.new(val[0].to_sym)
        
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 93)
  def _reduce_16(val, _values, result)
     @jot.push(0) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 95)
  def _reduce_17(val, _values, result)
     @jot.push(1) 
    result
  end
.,.,

# reduce 18 omitted

# reduce 19 omitted

def _reduce_none(val, _values, result)
  val[0]
end

  end   # class Parser
  end   # module RazyK
