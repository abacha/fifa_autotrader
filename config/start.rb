require 'sinatra/activerecord'
require 'chronic_duration'
require 'json'
require 'pry'

require './features/support/robot_logger'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/db.sqlite3')
ActiveRecord::Base.logger.level = ENV.fetch('LOG_LEVEL') { :info }

Dir['./lib/*'].each { |klass| require klass }
Dir['./web/models/*'].each { |klass| require klass }
