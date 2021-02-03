require './config/start.rb'

require 'sinatra'
require 'haml'
require 'action_view'

include ActionView::Helpers::NumberHelper
require_relative 'views/helpers'

Dir['./web/controllers/*'].each { |klass| require klass }

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
