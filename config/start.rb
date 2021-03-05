require 'sinatra/activerecord'
require 'chronic_duration'
require 'json'
require 'pry'

require './config/database'
require './features/support/robot_logger'

require './web/models/setting'

Dir['./lib/**/*.rb'].each { |klass| require klass }
Dir['./web/models/**/*.rb'].each { |klass| require klass }
