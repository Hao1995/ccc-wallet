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
# ActiveRecord::Base.logger = Logger.new(STDOUT)
logger = Logger.new(STDOUT)
logger.formatter = proc do |severity, timestamp, progname, msg|
  formatted_time = timestamp.strftime("%Y-%m-%d %H:%M:%S.%L") # Adds milliseconds
  thread_id = "Thread-#{Thread.current.object_id}"
  "[#{formatted_time}] #{severity} #{thread_id} [ActiveRecord]: #{msg}\n"
end
ActiveRecord::Base.logger = logger

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
