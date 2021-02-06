get '/matched_trades' do
  @matched_trades = MatchedTrade.order(timestamp: :desc).paginate(page: params[:page])
  haml :'matched_trades/index'
end
