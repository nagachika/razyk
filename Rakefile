require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

task :racc => [ "lib/razyk/parser.y" ] do
  sh "racc -o lib/razyk/parser.rb lib/razyk/parser.y"
end
