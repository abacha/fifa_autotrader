# frozen_string_literal: true

class SettingsController < ApplicationController
  before do
    @settings = Setting.masked_all
    params['setting'] ||= {}
  end

  get '/settings' do
    @setting = Setting.find_or_initialize_by(id: params['id']).mask
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
end
