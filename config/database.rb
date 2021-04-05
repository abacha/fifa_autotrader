connection_configs = connection_configs = YAML.load(File.read('config/database.yml'))
current_env = ENV['MY_ENV'] || 'development'
ActiveRecord::Base.establish_connection(connection_configs[current_env])

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ENV['DATABASE_FILE'], pool: 10)
ActiveRecord::Base.logger ||= Logger.new(STDOUT)
ActiveRecord::Base.logger.level = ENV.fetch('LOG_LEVEL') { :info }
