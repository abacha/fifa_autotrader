# frozen_string_literal: true

require 'sinatra/json'

class DashboardController < ApplicationController
  get '/' do
    haml :'dashboard/dashboard'
  end

  get '/log' do
    @log = Rack::Utils.escape_html RobotLogger.tail(params[:lines] || 15)
    json @log
  end

  get '/trades' do
    @trades = Trade.order(timestamp: :desc).first(10)
    haml :'dashboard/_trades', layout: false
  end

  get '/stock' do
    @stock = Stock.count
    haml :'reports/_stock', layout: false
  end

  get '/last_error' do
    @last_error = last_error
    haml :'dashboard/_last_error', layout: false
  end

  post '/command' do
    Command.queue(params[:command])
  end

  private

  def last_error
    image = Dir.glob('./web/public/errors/*.png').max
    return OpenStruct.new unless image

    basename = File.basename(image, '.*')

    img_path = image.gsub('./web/public', '')
    timestamp = basename.match(/\d{8}_\d{6}/)[0]
    error_msg = File.read("#{ENV['TMP_FOLDER']}/errors/#{basename}.log")

    OpenStruct.new(
      img_path: img_path,
      error_msg: error_msg,
      timestamp: DateTime.parse(timestamp).strftime('%Y-%m-%d %H:%M:%S')
    )
  end
end
