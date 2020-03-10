# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'redcarpet'
require 'yardstick/rake/measurement'
require 'yardstick/rake/verify'
require 'yard'

desc 'Preloaded Ruby Shell'
task :console do
  sh 'irb -rubygems -I lib -r bitfinex.rb'
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
end

Yardstick::Rake::Measurement.new(:yardstick_measure) do |measurement|
  measurement.output = 'measurement_report.txt'
end

Yardstick::Rake::Verify.new do |verify|
  verify.threshold = 100
end
