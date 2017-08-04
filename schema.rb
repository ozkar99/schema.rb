#!/usr/bin/ruby
require 'benchmark'

require_relative 'lib/config'
require_relative 'lib/options'
require_relative 'lib/command'

# Get commands and read config.
opts = Options.parse ARGV
conf = Config.read 'config.json'

# Execute command
time = Benchmark.measure do
  cmd = Command.new opts, conf
  cmd.exec
end

p "Finished Command, time: #{time.real}"