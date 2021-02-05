ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/db.sqlite3')
ActiveRecord::Base.logger ||= Logger.new(STDOUT)
ActiveRecord::Base.logger.level = ENV.fetch('LOG_LEVEL') { :info }
