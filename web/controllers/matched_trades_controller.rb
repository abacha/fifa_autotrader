# frozen_string_literal: true

class MatchedTradesController < ApplicationController
  get '/' do
    @q = MatchedTrade.ransack(params[:q])
    @matched_trades = @q.result.order(timestamp: :desc).paginate(page: params[:page])
    haml :'matched_trades/index'
  end
end
