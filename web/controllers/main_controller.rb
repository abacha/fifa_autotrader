require 'sinatra/json'

get '/' do
  @stock = Stock.count
  @trades = Trade.order(timestamp: :desc).first(10)
  @last_error = last_error
  @players = Player.all
  haml :dashboard
end

get '/log' do
  @log = Rack::Utils.escape_html RobotLogger.tail(params[:lines] || 15)
  json @log
end
