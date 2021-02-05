require 'sinatra/activerecord'
require 'chronic_duration'
require 'json'
require 'pry'

require './config/database'
require './features/support/robot_logger'


Dir['./lib/*'].each { |klass| require klass }
Dir['./web/models/*'].each { |klass| require klass }
