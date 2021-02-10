get '/reports/charts' do
  matched_trades = MatchedTrade.all.group(:date)
  @daily_profit = matched_trades.sum(:profit).values
  @trades  = matched_trades.count.values
  @avg_profit = matched_trades.average(:profit).values.map(&:round)
  @dates = matched_trades.count.keys.map(&:to_s)
  @stock = Stock.all

  @keys = ((Date.today-7)..Date.today).to_a.map(&:to_s)
  @players = @keys.map do |date|
    MatchedTrade.all.where(date: date).group(:player_name).count
  end

  haml :'/reports/charts'
end

get '/reports/players' do
  @reports = PlayerReport.all
  haml :'/reports/players'
end
