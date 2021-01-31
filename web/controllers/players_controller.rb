get '/players' do
  @players = Player.all
  @player = Player.find_by(name: params['name'])
  haml :'players/index'
end

post '/players' do
  Player.create!(params['player'])
  redirect '/players'
end

get '/players/status' do
  player = Player.find_by(name: params['name'])
  player.status = params['status'].to_i
  player.save!
  redirect '/players'
end
