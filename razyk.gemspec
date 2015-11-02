# -*- encoding: utf-8 -*-

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "razyk/version"

Gem::Specification.new do |s|
  s.name = "razyk"
  s.version = RazyK::VERSION
  s.authors = ["nagachika"]
  s.email = ["nagachika@ruby-lang.org"]

  s.summary = "pure ruby LazyK implementation"
  s.description = "RazyK is a LazyK implementetion by pure ruby."
  s.homepage = "http://github.com/nagachika/razyk"
  s.license = "Ruby"

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir = "bin"
  s.executables = ["razyk"]
  s.require_paths = ["lib"]
  s.has_rdoc = false

  s.required_ruby_version = ">= 2.0.0"

  s.add_runtime_dependency "ruby-graphviz"
  s.add_runtime_dependency "rack"

  s.add_development_dependency "bundler", "~> 1.10"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "racc"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "test-unit-power_assert"
  s.add_development_dependency "pry"
end

