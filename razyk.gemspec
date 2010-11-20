# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{razyk}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["nagachika"]
  s.date = %q{2010-11-20}
  s.default_executable = %q{razyk}
  s.description = %q{RazyK is a LazyK implementetion by pure ruby}
  s.email = %q{nagachika00@gmail.com}
  s.executables = ["razyk"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/razyk",
    "examples/lazier.scm",
    "examples/prelude.scm",
    "examples/prime.lazy",
    "examples/reverse.lazy",
    "examples/reverse.scm",
    "lib/razyk.rb",
    "lib/razyk/graph.rb",
    "lib/razyk/node.rb",
    "lib/razyk/parser.rb",
    "lib/razyk/parser.y",
    "lib/razyk/vm.rb",
    "lib/razyk/webapp.rb",
    "lib/razyk/webapp/templates/main.html",
    "razyk.gemspec",
    "spec/node_spec.rb",
    "spec/spec_helper.rb",
    "spec/vm_spec.rb"
  ]
  s.homepage = %q{http://github.com/nagachika/razyk}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{pure ruby LazyK implementation}
  s.test_files = [
    "spec/node_spec.rb",
    "spec/spec_helper.rb",
    "spec/vm_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_runtime_dependency(%q<rack>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-graphviz>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<ruby-graphviz>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<ruby-graphviz>, [">= 0"])
  end
end

