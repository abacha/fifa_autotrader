get '/matched_trades' do
  @matched_trades = MatchedTrade.order(timestamp: :desc)
  haml :'matched_trades/index'
end
