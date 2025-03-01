require 'rake'
require 'active_record'
require 'yaml'

# Load the database configuration
db_config = YAML.load_file('config/database.yml', aliases: true)
ActiveRecord::Base.configurations = db_config

# Customized tasks
namespace :db do
  desc 'Migrate the database'
  task :migrate do
    ActiveRecord::Base.establish_connection(:development)
    migrations_path = File.expand_path('db/migrate', __dir__)
    migration_context = ActiveRecord::MigrationContext.new(migrations_path)
    migration_context.up
  end
end
