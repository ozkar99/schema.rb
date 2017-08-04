require 'json'

class Config
    attr_reader :config

    def initialize filepath
        @config = read filepath
    end

    def self.read filepath
        file = File.read filepath
        JSON.parse file, symbolize_names: true
    end
end