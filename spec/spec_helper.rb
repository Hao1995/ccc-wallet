require 'bundler/setup'
require 'logger'
require 'active_record'
require 'active_record/migration'
require 'database_cleaner/active_record'

# Load the database configuration
db_config = YAML.load_file("#{Dir.pwd}/config/database.yml", aliases: true)
ActiveRecord::Base.configurations = db_config

def establish_connection_with_db_creation
  ActiveRecord::Base.establish_connection(:test)
  migrations_path = File.expand_path('db/migrate', __dir__)
  migration_context = ActiveRecord::MigrationContext.new(migrations_path)
  migration_context.up
end

# Establish the connection (creates the DB if needed)
ActiveRecord::Base.logger = Logger.new(STDOUT)
establish_connection_with_db_creation

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

# DatabaseCleaner
DatabaseCleaner.strategy = :truncation
