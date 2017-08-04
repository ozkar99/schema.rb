require 'mysql2'

class Command

    attr_reader :command, :name, :host, :port, :user, :pass, :database, :sql_client

    def initialize opts, conf
        @command = opts[:command]
        @name = opts[:name] if @command == :add

        @host = conf[:host]
        @port = conf[:port]
        @user = conf[:user]
        @pass = conf[:pass]
        @database = conf[:database]

        initialize_sql_client
    end

    def exec
        send "run_#{@command.to_s}" # call the private methods based on command via meta-programming.
    end

    private
    def initialize_sql_client
        @sql_client = Mysql2::Client.new username: @user, password: @pass, port: @port, host: @host # no database specified
        @database = @sql_client.escape @database
    end

    def run_create
        p "Creating database (if not exists)"
        @sql_client.query "CREATE DATABASE IF NOT EXISTS #{@database};"
        
        p "Creating _migrations table (if not exists)"
        @sql_client.query "USE #{@database};"
        @sql_client.query "CREATE TABLE IF NOT EXISTS _migrations (ID INT NOT NULL, Migration VARCHAR(120), Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (ID));"
    end

    def run_add
        p "Creating migration"
        
        # validate that @name is < 120 chars
        # get timestamp
        # filename = "#{timestamp}_{@name}.sql"        
        # touch file in migrations/filename
        # ez pz method
    end

    def run_migrate
        p "Running migrations"
        
        results = @sql_client.query "SHOW DATABASES LIKE '#{@database}';"
        unless results.any?
            p "Database has not been created please run 'create' command first to create database."
            return
        end

        @sql_client.query "USE #{@database};"
        result = @sql_client.query "SHOW TABLES LIKE '_migrations';"
        unless result.any?
            p "Database has not been initialized please run 'create' command first to add _migrations table."
            return
        end
        
        # get /migration files
        # get latest migration from db
        # grab the ones not migrated yet
        # iterate and execute files
        # add entry in _migrations for each executed file
    end
end