get '/' do
  @reports = Manager.reports
  @stock = Stock.all
  @trades = Trade.order(timestamp: :desc).first(10)
  @log = Rack::Utils.escape_html RobotLogger.tail(10)
  @last_error = last_error
  @players = Player.all
  haml :dashboard
end

get '/trades' do
  @trades = Trade.order(timestamp: :desc)
  haml :_trades
end

get '/log' do
  @log = Rack::Utils.escape_html RobotLogger.tail(300)
  haml :_log
end
