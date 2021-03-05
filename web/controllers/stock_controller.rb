# frozen_string_literal: true

get '/stock' do
  @stock = Stock.full_stock
  haml :'stock/index'
end
