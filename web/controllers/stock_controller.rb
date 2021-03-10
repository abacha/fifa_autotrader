# frozen_string_literal: true

class StockController < ApplicationController
  get '/stock' do
    @stock = Stock.full_stock
    haml :'stock/index'
  end
end
