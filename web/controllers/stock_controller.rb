# frozen_string_literal: true

get '/stock' do
  @stock = Stock.all
  haml :'stock/index'
end
