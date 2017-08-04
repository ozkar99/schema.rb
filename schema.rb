#!/usr/bin/env ruby

require 'bundler/setup'
require 'benchmark'

require_relative 'lib/config'
require_relative 'lib/options'
require_relative 'lib/command'

# Get commands and read config.
opts = Schema::Options.parse ARGV
conf = Schema::Config.read 'config.json'

# Execute command
time = Benchmark.measure do
  cmd = Schema::Command.new opts, conf
  cmd.exec
end

p "Finished Command, time: #{time.real}"