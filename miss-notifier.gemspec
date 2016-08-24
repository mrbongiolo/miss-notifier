# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'miss/notifier/version'

Gem::Specification.new do |spec|
  spec.name          = "miss-notifier"
  spec.version       = Miss::Notifier::VERSION
  spec.authors       = ["Ralf Schmitz Bongiolo"]
  spec.email         = ["mrbongiolo@gmail.com"]
  spec.summary       = "Easy notifications by Push and SMS."
  spec.homepage      = "http://github.com/mrbongiolo/miss-notifier"
  spec.license       = "MIT"

  spec.files         = Dir["README.md", "LICENSE.md", "Gemfile*", "Rakefile", "lib/**/*", "spec/**/*"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
