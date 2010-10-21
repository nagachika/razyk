require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "razyk"
    gem.summary = %Q{pure ruby LazyK implementation}
    gem.description = %Q{RazyK is a LazyK implementetion by pure ruby}
    gem.email = "nagachika00@gmail.com"
    gem.homepage = "http://github.com/nagachika/razyk"
    gem.authors = ["nagachika"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new(:spec) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.spec_files = FileList['spec/**/*_spec.rb']
  end

  Spec::Rake::SpecTask.new(:rcov) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rcov = true
  end

  task :spec => :check_dependencies
rescue LoadError
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)

  RSpec::Core::RakeTask.new(:rcov) do |spec|
    spec.rcov = true
  end

  task :spec => :check_dependencies
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "razyk #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
