# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'filename/version'

Gem::Specification.new do |spec|
  spec.name          = "filename"
  spec.version       = FileName::VERSION
  spec.authors       = ["Takayuki YAMAGUCHI"]
  spec.email         = ["d@ytak.info"]
  spec.description   = "File name generator with sequential number or time string"
  spec.summary       = "Create filename with sequential number or time string that is not duplicated."
  spec.homepage      = ""
  spec.license       = "GPLv3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "yard"
end
