# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'modified_bayes/version'

Gem::Specification.new do |spec|
  spec.name          = "modified_bayes"
  spec.version       = ModifiedBayes::VERSION
  spec.authors       = ["Krishna Dole"]
  spec.email         = ["krishna@collaborativedrug.com"]
  spec.description   = %q{Naïve Bayesian model optimized for sparse datasets}
  spec.summary       = %q{Naïve Bayesian model for sparse datasets}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
