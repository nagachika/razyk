
require "razyk/dag"
require "razyk/parser"
require "razyk/vm"
require "razyk/graph"

module RazyK
  def self.run(program, opt={}, &blk)
    opt[:input] ||= $stdin
    opt[:output] ||= $stdout
    tree = Parser.parse(program, opt)
    root = Pair.new(:OUTPUT, Pair.new(tree, :INPUT))
    vm = VM.new(root, opt[:input], opt[:output])

    if blk
      vm.run(&blk)
    else
      vm.run
    end
  end
end
