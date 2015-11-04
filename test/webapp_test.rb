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
  ]
  i_series.each_cons(2).with_index do |(before, after), idx|
    testdata["i_#{idx}"] = [before, after]
  end
  testdata["i_ab"] = [
    ["(($PUTC ((($IN K) $INC) $0)) ($OUT ($CDR $IN)))", "", "ab", ""],
    ["(($PUTC (((((S ((S I) (K $97))) (K $IN)) K) $INC) $0)) ($OUT ($CDR ((S ((S I) (K $97))) (K $IN)))))", "a", "b", ""]
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
