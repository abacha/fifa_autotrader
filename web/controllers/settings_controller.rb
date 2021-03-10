# frozen_string_literal: true

class SettingsController < ApplicationController
  before do
    @settings = Setting.masked_all
    params['setting'] ||= {}
  end

  get '/' do
    @setting = Setting.find_or_initialize_by(id: params['id']).mask
    haml :'settings/index'
  end

  post '/' do
    @setting = Setting.find_or_initialize_by(id: params['setting']['id'])

    if @setting.update(params['setting'])
      redirect '/settings'
    else
      haml :'settings/index'
    end
  end
end
