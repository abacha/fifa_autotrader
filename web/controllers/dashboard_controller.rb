# frozen_string_literal: true

require 'sinatra/json'

get '/' do
  haml :'dashboard/dashboard'
end

get '/dashboard/log' do
  @log = Rack::Utils.escape_html RobotLogger.tail(params[:lines] || 15)
  json @log
end

get '/dashboard/trades' do
  @trades = Trade.order(timestamp: :desc).first(10)
  haml :'dashboard/_trades', layout: false
end

get '/dashboard/stock' do
  @stock = Stock.count
  haml :'reports/_stock', layout: false
end

get '/dashboard/last_error' do
  @last_error = ErrorCapturer.last_error
  haml :'dashboard/_last_error', layout: false
end

post '/dashboard/command' do
  Command.queue(params[:command])
end
