get '/trades' do
  @trades = Trade.order(timestamp: :desc).paginate(page: params[:page])
  haml :'trades/index'
end
