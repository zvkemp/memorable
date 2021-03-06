# coding: utf-8
require File.expand_path('lib/memorable/version')

Gem::Specification.new do |spec|
  spec.name          = "memorable"
  spec.version       = Memorable::VERSION
  spec.authors       = ["zvkemp"]
  spec.email         = ["zvkemp@gmail.com"]
  spec.summary       = %q{Memoizes method calls.}
  spec.description   = %q{Memoizes method calls.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
