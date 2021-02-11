before do
  @settings = Setting.all
  params['setting'] ||= {}
end

get '/settings' do
  @setting =
    if params['id']
      Setting.find(params['id'])
    else
      Setting.new
    end

  haml :'settings/index'
end

post '/settings' do
  @setting = Setting.find_or_initialize_by(id: params['setting']['id'])

  if @setting.update_attributes(params['setting'])
    redirect '/settings'
  else
    haml :'settings/index'
  end
end
