require 'mysql2'
require_relative 'strings_patch'
require_relative 'mysql2_patch'

module Schema
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
            @sql_client = Mysql2::Client.new username: @user, password: @pass, port: @port, host: @host, flags: Mysql2::Client::MULTI_STATEMENTS # no database specified
            @database = @sql_client.escape @database
        end

        def run_create
            p "Creating database (if not exists)"
            @sql_client.query "CREATE DATABASE IF NOT EXISTS #{@database};"
            
            p "Creating _migrations table (if not exists)"
            @sql_client.query "USE #{@database};"
            @sql_client.query "CREATE TABLE IF NOT EXISTS _migrations (ID INT NOT NULL AUTO_INCREMENT, Migration VARCHAR(120), Timestamp TIMESTAMP(4) DEFAULT CURRENT_TIMESTAMP(4), PRIMARY KEY (ID));"
        end

        def run_add
            p "Creating migration"
            filename = "#{Time.now.to_i}_#{@name}"

            if filename.length > 120
                p "Maximum size for migration name reached (120 chars, including timestamp_)"
                return
            end

            filename = filename + ".sql"
            File.write "migrations/#{filename}", "-- Auto-Generated by scheme.rb: #{filename}"
            p "Migration created #{filename}"
        end

        def run_migrate
            p "Running migrations"

            # check if database exists
            results = @sql_client.query "SHOW DATABASES LIKE '#{@database}';"
            unless results.any?
                p "Database has not been created please run 'create' command first to create database."
                return
            end

            # check if _migrations table exists
            @sql_client.query "USE #{@database};"
            result = @sql_client.query "SHOW TABLES LIKE '_migrations';"
            unless result.any?
                p "Database has not been initialized please run 'create' command first to add _migrations table."
                return
            end
            
            # get all migrations
            migrations = Dir.glob "migrations/*.sql"
            migrations = migrations.map { |m| m.base_name } # remove path and extension

            # if there are migrations only get the ones that hasnt been applied yet.
            last_migration = @sql_client.query "SELECT Migration FROM _migrations ORDER BY Timestamp,Migration DESC;"
            if last_migration.any?
                last_migration = last_migration.first["Migration"]
                migrations = migrations.drop_while { |m| m != last_migration} # drops till last_migration
                migrations.shift # removes last_migration element
            end

            # iterate the migration files
            migrations.sort.each do |migration|

                base_name = @sql_client.escape migration.base_name
                sql = File.read "migrations/#{migration}.sql"

                @sql_client.transaction do 
                    @sql_client.query sql # execute sql file

                    @sql_client.abandon_results! # clean buffer (needed for multi-statements)
                    @sql_client.query "INSERT INTO _migrations (Migration) VALUES ('#{base_name}');" # add entry to _migrations
                    @sql_client.abandon_results!
                end

                p "Executed Migration #{base_name}"
            end
        end
    end
end
