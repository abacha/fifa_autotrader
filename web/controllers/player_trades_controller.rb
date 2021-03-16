# frozen_string_literal: true

class PlayerTradesController < ApplicationController
  before do
    @players = PlayerTrade.all.order(status: :desc, name: :asc)
    params['player'] ||= {}
  end

  get '/' do
    @player = PlayerTrade.find_or_initialize_by(id: params['id'])
    haml :'player_trades/index'
  end

  post '/' do
    @player = PlayerTrade.find_or_initialize_by(id: params['player']['id'])

    if @player.update(params['player'])
      redirect '/player_trades'
    else
      haml :'player_trades/index'
    end
  end

  get '/status' do
    player = PlayerTrade.find_by(name: params['name'])
    player.update!(status: params['status'].to_i)
    redirect '/player_trades'
  end

  get '/refresh_cache' do
    cache = PlayerTrade.all.map.each do |player|
      player.futbin_market_data
    end

    json cache
  end
end
