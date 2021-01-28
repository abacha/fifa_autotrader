require 'sinatra'
require 'sinatra/reloader'
require 'haml'

require 'action_view'

require_relative '../lib/manager'
require_relative '../features/support/robot_logger'
include ActionView::Helpers::NumberHelper

get '/' do
  @reports = Manager.reports
  @stock = Stock.all
  @trades = Trade.all.last(10).reverse
  @log = Rack::Utils.escape_html RobotLogger.tail(30)
  @last_error = last_error
  haml :index
end

get '/trades' do
  @trades = Trade.all.reverse
  haml :_trades
end

get '/log' do
  @log = Rack::Utils.escape_html RobotLogger.tail(300)
  haml :_log
end

def last_error
  image = Dir['web/public/screenshots/*.png'].sort.last

  if image
    hash = image.match(/screenshots\/(.*?)\./)[1]
    img_path = image.gsub('web/public', '')
    timestamp = image.match(/\d{8}_\d{6}/)[0]
    error_msg = File.read("tmp/errors/#{hash}.log")

    OpenStruct.new(
      img_path: img_path,
      error_msg: error_msg,
      timestamp: DateTime.parse(timestamp).strftime('%Y-%m-%d %H:%M:%S')
    )
  else
    OpenStruct.new
  end
end
