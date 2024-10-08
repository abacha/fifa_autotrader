# frozen_string_literal: true

class TradesController < ApplicationController
  get '/' do
    @q = Trade.ransack(params[:q])
    @trades = @q.result.order(timestamp: :desc).paginate(page: params[:page])
    haml :'trades/index'
  end

  delete '/' do
    trade = Trade.find(params['id'])
    trade.destroy
  end
end
