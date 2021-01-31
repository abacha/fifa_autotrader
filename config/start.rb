require 'sinatra/activerecord'

# set :database, {adapter: 'sqlite3', database: 'db/db.sqlite3'}
ActiveRecord::Base.establish_connection({adapter: 'sqlite3', database: 'db/db.sqlite3'})
Dir['./web/models/*'].each { |klass| require klass }
