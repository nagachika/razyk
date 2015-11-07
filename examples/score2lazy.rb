require_relative "encoder"

scores = $stdin.read.split(/\s+/m)
tempo = scores.shift.to_i

def name2tone(s)
  /\A(\d*)([A-G])(\d+)([-+]?)\z/ =~ s
  l = Regexp.last_match(1)
  k = Regexp.last_match(2)
  o = Regexp.last_match(3)
  shift = Regexp.last_match(4)
  if l == ""
    l = 1
  else
    l = l.to_i
  end
  o = o.to_i
  k = {"C" => 0, "D" => 2, "E" => 4, "F" => 5, "G" => 7, "A" => 9, "B" => 11}[k]
  if shift == "-"
    k -= 1
    if k == -1
      o -= 1
      k = 11
    end
  elsif shift == "+"
    k += 1
    if k == 12
      o += 1
      k = 0
    end
  end
  [l, o, k]
end

lazy = "K" + ary2list([tempo, scores.map{|s| name2tone(s) }].flatten)
puts lazy

system("bundle exec razyk --audio -e '#{lazy}'")
