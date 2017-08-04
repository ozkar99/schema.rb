class Command

    attr_reader :command, :name, :host, :port, :user, :pass, :database

    def initialize opts, conf
        @command = opts[:command]
        @name = opts[:name] if @command == :add

        @host = conf[:host]
        @port = conf[:port]
        @user = conf[:user]
        @pass = conf[:pass]
        @database = conf[:database]
    end

    def exec
        send "run_#{@command.to_s}" # call the private methods based on command via metra-programming.
    end
    
    private
    def run_create
       p "Creating database..."
    end

    def run_migrate
        p "Running migrations..."
    end

    def run_add
        p "Creating migration..."
    end
end