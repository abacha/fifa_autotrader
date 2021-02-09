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

get '/graphs' do
  @daily_profit = Hash[MatchedTrade.all.group(:date).sum(:profit).map { |k, v| [k.to_s, v] }]
  @trades  = Hash[MatchedTrade.all.group(:date).count.map { |k, v| [k.to_s, v] }]
  @avg_profit = Hash[MatchedTrade.all.group(:date).average(:profit).map { |k, v| [k.to_s, v.round] }]
  @dates = @daily_profit.keys
  @stock = Stock.all
  haml :graphs
end
