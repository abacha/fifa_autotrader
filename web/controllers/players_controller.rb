before do
  @players = Player.all.order(:name)
  params['player'] ||= []
end

get '/players' do
  @player = Player.find_by(name: params['name']) || Player.new(status: 1)
  haml :'players/index'
end

post '/players' do
  @player = Player.find_or_initialize_by(id: params['player']['id'])

  if @player.update_attributes(params['player'])
    redirect '/players'
  else
    haml :'players/index'
  end
end

get '/players/status' do
  player = Player.find_by(name: params['name'])
  player.status = params['status'].to_i
  player.save!
  redirect '/players'
end
