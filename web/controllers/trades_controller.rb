# frozen_string_literal: true

get '/trades' do
  @q = Trade.ransack(params[:q])
  @trades = @q.result.order(timestamp: :desc).paginate(page: params[:page])
  haml :'trades/index'
end
