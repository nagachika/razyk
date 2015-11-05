
require "razyk/node"
require "razyk/parser"
require "razyk/vm"

module RazyK
  def self.run(program, opt={}, &blk)
    opt[:input] ||= $stdin
    if opt[:audio]
      opt[:output] = RazyK::Audio::Port.new
    else
      opt[:output] ||= $stdout
    end
    opt[:memory] ||= {}
    tree = Parser.parse(program, opt)
    root = Pair.new(:OUT, Pair.new(tree, :IN))
    vm = VM.new(root, opt[:input], opt[:output], recursive: opt[:recursive], statistics: opt[:statistics])

    if blk
      vm.run(&blk)
    else
      vm.run
    end
  end
end
