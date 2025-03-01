require 'bundler/setup'
require 'logger'
require 'active_record'
require 'active_record/migration'

# Database configuration using environment variables
db_config = {
  adapter:  'mysql2',
  host:     ENV.fetch('MYSQL_HOST', '127.0.0.1'),
  username: ENV.fetch('MYSQL_USERNAME', 'root'),
  password: ENV.fetch('MYSQL_PASSWORD', 'password'),
  database: ENV.fetch('MYSQL_TEST_DATABASE', 'wallet_test')
}

def establish_connection_with_db_creation(config)
  begin
    ActiveRecord::Base.establish_connection(config)
    # Verify connection by accessing the connection
    ActiveRecord::Base.connection
  rescue ActiveRecord::NoDatabaseError
    puts "Database #{config[:database]} not found. Creating..."
    create_database(config)
    ActiveRecord::Base.establish_connection(config)
  end
end

def create_database(config)
  system(%Q(mysql -h #{config[:host]} -u#{config[:username]} -p#{config[:password]} -e "CREATE DATABASE IF NOT EXISTS #{config[:database]};"))
end

# Establish the connection (creates the DB if needed)
ActiveRecord::Base.logger = Logger.new(STDOUT)
establish_connection_with_db_creation(db_config)

# Run migrations programmatically
migrations_path = File.expand_path('../../db/migrate', __FILE__)
migration_context = ActiveRecord::MigrationContext.new(migrations_path)

puts "Running migrations..."
if ActiveRecord::VERSION::MAJOR >= 6
  migration_context.migrate
else
  ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
end
puts "Migrations complete."
