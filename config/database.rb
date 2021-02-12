ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ENV['DATABASE_FILE'])
ActiveRecord::Base.logger ||= Logger.new(STDOUT)
ActiveRecord::Base.logger.level = ENV.fetch('LOG_LEVEL') { :info }
