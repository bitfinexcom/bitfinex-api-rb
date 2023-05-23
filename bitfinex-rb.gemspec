# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'bitfinex-rb'
  spec.version       = '1.0.9'
  spec.authors       = ['Bitfinex']
  spec.email         = ['developers@bitfinex.com']
  spec.summary       = %q{Bitfinex API Wrapper}
  spec.description   = %q{Official Bitfinex API ruby wrapper}
  spec.homepage      = 'https://www.bitfinex.com/'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.add_runtime_dependency 'faraday', '~> 1'
  spec.add_runtime_dependency 'socksify', "~> 1.7"
  spec.add_runtime_dependency 'eventmachine', '~> 1.2.7', '>= 1.2.7'
  spec.add_runtime_dependency 'faraday-detailed_logger', '~> 2.5'
  spec.add_runtime_dependency 'faye-websocket', '~> 0.11'
  spec.add_runtime_dependency 'json', '~> 2.2','>= 2.2'
  spec.add_runtime_dependency 'faraday_middleware', '~> 1'
  spec.add_runtime_dependency 'emittr', '~> 0.1.0', '>= 0.1.0'
  spec.add_runtime_dependency 'dotenv', '~> 2.5', '>= 2.5'
  spec.add_runtime_dependency 'zlib', '~> 1.0.0', '>= 1.0.0'
end
