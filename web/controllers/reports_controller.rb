# frozen_string_literal: true

get '/reports/charts' do
  matched_trades = MatchedTrade.all.group(:date)
  @dates = matched_trades.pluck(:date).map(&:to_s)

  @daily_profit = matched_trades.sum(:profit).map { |k, v| [k.to_s, v] }
  @avg_profit = matched_trades.average(:profit).map { |k, v| [k.to_s, v] }

  @trades = Trade.all.group(:date, :kind).count.map { |k, v| [k[0].to_s, k[1], v] }

  @keys = ((Date.today - 7)..Date.today).to_a.map(&:to_s)
  @players = @keys.map do |date|
    MatchedTrade.all.where(date: date).group(:player_name).count
  end

  haml :'/reports/charts'
end

get '/reports/players' do
  @reports = PlayerReport.all
  haml :'/reports/players'
end
