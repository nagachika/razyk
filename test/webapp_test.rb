# encoding: utf-8

require "test_helper"

require "razyk/webapp"

require "ostruct"

class RazyKWebAppTest < Test::Unit::TestCase

  testdata = {}
  i_series = [
    ["($OUT (I $IN))", "", "a", ""],
    ["(($PUTC ((($CAR (I $IN)) $INC) $0)) ($OUT ($CDR (I $IN))))", "", "a", ""],
    ["(($PUTC ((((I $IN) K) $INC) $0)) ($OUT ($CDR (I $IN))))", "", "a", ""],
    ["(($PUTC ((($IN K) $INC) $0)) ($OUT ($CDR $IN)))", "", "a", ""],
    ["(($PUTC ((((($CONS $97) $IN) K) $INC) $0)) ($OUT ($CDR (($CONS $97) $IN))))", "a", "", ""],
    ["(($PUTC ((((K $97) $IN) $INC) $0)) ($OUT ($CDR (($CONS $97) $IN))))", "a", "", ""],
    ["(($PUTC (($97 $INC) $0)) ($OUT ($CDR (($CONS $97) $IN))))", "a", "", ""],
    ["(($PUTC $97) ($OUT ($CDR (($CONS $97) $IN))))", "a", "", ""],
    ["($OUT ($CDR (($CONS $97) $IN)))", "a", "", "a"],
    ["(($PUTC ((($CAR ($CDR (($CONS $97) $IN))) $INC) $0)) ($OUT ($CDR ($CDR (($CONS $97) $IN)))))", "a", "", "a"],
    ["(($PUTC (((($CDR (($CONS $97) $IN)) K) $INC) $0)) ($OUT ($CDR ($CDR (($CONS $97) $IN)))))", "a", "", "a"],
    ["(($PUTC (((((($CONS $97) $IN) (K I)) K) $INC) $0)) ($OUT ($CDR ((($CONS $97) $IN) (K I)))))", "a", "", "a"],
    ["(($PUTC ((((((K I) $97) $IN) K) $INC) $0)) ($OUT ($CDR (((K I) $97) $IN))))", "a", "", "a"],
    ["(($PUTC ((((I $IN) K) $INC) $0)) ($OUT ($CDR (I $IN))))", "a", "", "a"],
    ["(($PUTC ((($IN K) $INC) $0)) ($OUT ($CDR $IN)))", "a", "", "a"],
    ["(($PUTC ((((($CONS $256) $IN) K) $INC) $0)) ($OUT ($CDR (($CONS $256) $IN))))", "a", "", "a"],
    ["(($PUTC ((((K $256) $IN) $INC) $0)) ($OUT ($CDR (($CONS $256) $IN))))", "a", "", "a"],
    ["(($PUTC (($256 $INC) $0)) ($OUT ($CDR (($CONS $256) $IN))))", "a", "", "a"],
    ["(($PUTC $256) ($OUT ($CDR (($CONS $256) $IN))))", "a", "", "a"],
  ]
  i_series.each_cons(2).with_index do |(before, after), idx|
    testdata["i_#{idx}"] = [before, after]
  end
  testdata["i_aa"] = [
    ["(($PUTC ((($IN K) $INC) $0)) ($OUT ($CDR $IN)))", "", "ab", ""],
    ["(($PUTC ((((($CONS $97) $IN) K) $INC) $0)) ($OUT ($CDR (($CONS $97) $IN))))", "a", "b", ""]
  ]
  data(testdata)
  def test_webapp_reduce(data)
    before, after = data
    expression, stdin_read, stdin_remain, stdout = before
    req = OpenStruct.new(params: {
      "expression" => expression,
      "stdin_read" => stdin_read,
      "stdin_remain" => stdin_remain,
      "stdout" => stdout,
    })
    app = RazyK::WebApp.new
    res = app.reduce(req)

    jobj = JSON.parse(res.body.first)
    power_assert { jobj["expression"] == after[0] }
    power_assert { jobj["stdin_read"] == after[1] }
    power_assert { jobj["stdin_remain"] == after[2] }
    power_assert { jobj["stdout"] == after[3] }
  end
end
