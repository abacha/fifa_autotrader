get '/stock' do
  @stock = Stock.all
  haml :'stock/index'
end

