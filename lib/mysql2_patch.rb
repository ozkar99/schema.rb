module Mysql2
    class Client
        # transaction monkey-patch
        def transaction &block
            raise ArgumentError, "No block was given" unless block_given?
            begin
                self.query("START TRANSACTION")
                self.query("SET autocommit=0")
                yield
                self.query("COMMIT")
            rescue
                self.query("ROLLBACK")
                raise # propagate error
            end
        end
    end
end