require_relative 'views/helpers'

get '/' do
  @reports = Manager.reports
  @stock = Stock.all
  @trades = Trade.all.last(10).reverse
  @log = Rack::Utils.escape_html RobotLogger.tail(30)
  @last_error = last_error
  @players = PlayerRepository.all
  haml :index
end

get '/trades' do
  @trades = Trade.all.reverse
  haml :_trades
end

get '/log' do
  @log = Rack::Utils.escape_html RobotLogger.tail(300)
  haml :_log
end

get '/players' do
  @players = PlayerRepository.all
  haml :players
end
