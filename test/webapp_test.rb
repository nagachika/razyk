# encoding: utf-8

require "test_helper"

require "razyk/webapp"

require "ostruct"

class RazyKWebAppTest < Test::Unit::TestCase

  testdata = {}
  # simple combinator reduction test without in/out
  [["IK", "K"], ["KIS", "I"], ["S$x$y$z", "(($x $z) ($y $z))"]].each do |before, after|
    testdata[before.downcase] = [[ before, "", "ab", ""], [after, "", "ab", ""]]
  end

  # in/out combinators
  testdata["in_car"] = [["$IN K", "", "ab", ""], ["(((S ((S I) (K $97))) (K $IN)) K)", "a", "b", ""]]
  testdata["out"] = [["$OUT K", "", "ab", ""], ["(($PUTC (((K K) $INC) $0)) ($OUT (K (S K))))", "", "ab", ""]]
  testdata["putc"] = [["$PUTC $97 $y", "", "ab", ""], ["$y", "", "ab", "a"]]

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
