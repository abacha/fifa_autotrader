require 'sinatra'
require 'sinatra/reloader'
require 'haml'

require 'action_view'

require_relative '../lib/manager'
include ActionView::Helpers::NumberHelper

get '/' do
  @reports = Manager.reports
  @total = Manager.total
  @stock = Stock.all
  @trades = Trade.all.last(15).reverse
  @last_error = last_error
  haml :index
end

get '/trades' do
  @trades = Trade.all.reverse
  haml :_trades
end

def last_error
  image = Dir['public/screenshots/*.png'].sort.last

  if image
    screenshot = image.gsub('public', '')
    timestamp = image.match(/\d{8}_\d{6}/)[0]
    error_msg = File.read
    OpenStruct.new(
      img_path: screenshot,
      error_msg: error_msg,
      timestmap: DateTime.parse(timestamp).strftime('%Y-%m-%d %H:%M:%S')
    )
  else
    OpenStruct.new
  end

end
