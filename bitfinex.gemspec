# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitfinex/version'

Gem::Specification.new do |spec|
  spec.name          = 'bitfinex'
  spec.version       = Bitfinex::VERSION
  spec.authors       = ['Bitfinex']
  spec.email         = ['developers@bitfinex.com']
  spec.summary       = %q{Bitfinex API Wrapper}
  spec.description   = %q{Simple Bitfinex API ruby wrapper}
  spec.homepage      = 'https://www.bitfinex.com/'
  spec.license       = ''

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday'
  spec.add_dependency 'json'
  spec.add_dependency 'faraday_middleware'
  spec.add_development_dependency "bundler"
end
