# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitfinex/version'

Gem::Specification.new do |spec|
  spec.name          = 'bitfinex-rb'
  spec.version       = Bitfinex::VERSION
  spec.authors       = ['Bitfinex']
  spec.email         = ['developers@bitfinex.com']
  spec.summary       = %q{Bitfinex API Wrapper}
  spec.description   = %q{Simple Bitfinex API ruby wrapper}
  spec.homepage      = 'https://www.bitfinex.com/'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*'] #`git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.add_runtime_dependency 'faraday', '~> 0.9.2', '>= 0.9.2'
  spec.add_runtime_dependency 'eventmachine', '~> 1.0', '>= 1.0.9.1'
  spec.add_runtime_dependency 'faraday-detailed_logger', '~> 1.0.0', '>= 1.0.0'
  spec.add_runtime_dependency 'faye-websocket', '~> 0.10.3'
  spec.add_runtime_dependency 'json', '~> 1.8.3','>= 1.8.3'
  spec.add_runtime_dependency 'faraday_middleware', '~> 0.10', '>= 0.10.0'
end
