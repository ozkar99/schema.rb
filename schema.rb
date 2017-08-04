#!/usr/bin/ruby

require_relative 'lib/config'
require_relative 'lib/options'
require_relative 'lib/command'

# Get commands and read config.
opts = Options.parse ARGV
conf = Config.read 'config.json'

# Execute command
cmd = Command.new opts, conf
cmd.exec
