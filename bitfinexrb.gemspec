# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitfinexrb/version'

Gem::Specification.new do |spec|
  spec.name          = 'bitfinex-api-rb'
  spec.version       = Bitfinexrb::VERSION
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

  spec.add_dependency 'httparty'
  spec.add_dependency 'eventmachine'
  spec.add_dependency 'faye-websocket'
  spec.add_dependency 'json'
  spec.add_dependency 'active_support'

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency 'rake'
end
