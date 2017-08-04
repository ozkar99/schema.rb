module Schema
    class Options
        def self.parse argv
            options = {}
            case argv.first
            when 'create'
                options[:command] = :create
            when 'migrate'
                options[:command] = :migrate
            when 'add'
                options[:command] = :add
                if argv.count <= 1
                    puts 'Usage: ./schema.rb add <name>'
                    exit
                else
                    options[:name] = argv[1]
                end
            else
                printf %{Usage:
    ./schema.rb create -- initializes database
    ./schema.rb migrate -- migrates database to latest version
    ./schema.rb add <name> -- creates migration file}
                exit
            end
            options
        end
    end
end