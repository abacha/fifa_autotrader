get '/players' do
  @players = PlayerRepository.all
  @player = PlayerRepository.find(params['name'])
  haml :'players/index'
end

post '/players' do
  player = Player.new(params['player'])
  PlayerRepository.save(player)
  redirect '/players'
end

get '/players/status' do
  player = PlayerRepository.find(params['name'])
  player.status = params['status']
  PlayerRepository.save(player)
  redirect '/players'
end
