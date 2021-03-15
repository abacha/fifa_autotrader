# frozen_string_literal: true

class PlayersController < ApplicationController
  before do
    @players = Player.all.order(status: :desc, name: :asc)
    params['player'] ||= {}
  end

  get '/' do
    @player = Player.find_or_initialize_by(id: params['id'])
    haml :'players/index'
  end

  post '/' do
    @player = Player.find_or_initialize_by(id: params['player']['id'])

    if @player.update(params['player'])
      redirect '/players'
    else
      haml :'players/index'
    end
  end

  get '/status' do
    player = Player.find_by(name: params['name'])
    player.update!(status: params['status'].to_i)
    redirect '/players'
  end

  get '/refresh_cache' do
    cache = Player.all.map.each do |player|
      player.futbin_market_data
    end

    json cache
  end
end
