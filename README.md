## schema.rb
Simple migration tool, only works for mysql/mariadb.

### Usage:
- Clone this repo to your target.
- Fill `config.json` with the database credentials.
- `./schema.rb create`: Initializes the database, creates `_migrations` table.
- `./schema.rb migrate`: Updates database to latest migration.
- `./schema.rb add <migrationname>`: creates new migration file on `migrations/`

### Grant access to a new user for running the tool:
- `mysql -u root -p`
- `CREATE USER 'newuser'@'%' IDENTIFIED BY 'password';`
- `GRANT ALL PRIVILEGES ON sample_database.* TO 'newuser'@'%';`

Make sure to change `newuser` and `sample_database` to your desired user and database name.