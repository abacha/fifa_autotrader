# frozen_string_literal: true

class PlayerSnipesController < ApplicationController
  before do
    @players = PlayerSnipe.all.order(status: :desc, name: :asc)
    params['player'] ||= {}
  end

  get '/' do
    @player = PlayerSnipe.find_or_initialize_by(id: params['id'])
    haml :'player_snipes/index'
  end

  post '/' do
    @player = PlayerSnipe.find_or_initialize_by(id: params['player']['id'])

    if @player.update(params['player'])
      redirect '/player_snipes'
    else
      haml :'player_snipes/index'
    end
  end

  delete '/' do
    @player = PlayerSnipe.find(params['id'])
    @player.destroy
  end

  get '/status' do
    player = PlayerSnipe.find_by(name: params['name'])
    player.update!(status: params['status'].to_i)
    redirect '/player_snipes'
  end
end
