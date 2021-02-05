require 'sinatra/json'

get '/' do
  @reports = PlayerReport.all
  @stock = Stock.all
  @trades = Trade.order(timestamp: :desc).first(10)
  @log = Rack::Utils.escape_html RobotLogger.tail(10)
  @last_error = last_error
  @players = Player.all
  haml :dashboard
end

get '/log' do
  @log = Rack::Utils.escape_html RobotLogger.tail(300)
  haml :_log
end
