require './config/start.rb'

require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require 'action_view'
require 'will_paginate'
require 'will_paginate/active_record'
require 'will_paginate/view_helpers/sinatra'

include ActionView::Helpers::NumberHelper

Dir['./web/views/helpers/*'].each { |klass| require klass }
Dir['./web/controllers/*'].each { |klass| require klass }

def last_error
  image = Dir['web/public/screenshots/*.png'].sort.last

  if image
    hash = image.match(/screenshots\/(.*?)\./)[1]
    img_path = image.gsub('web/public', '')
    timestamp = image.match(/\d{8}_\d{6}/)[0]
    error_msg = File.read("#{ENV['TMP_FOLDER']}/errors/#{hash}.log")

    OpenStruct.new(
      img_path: img_path,
      error_msg: error_msg,
      timestamp: DateTime.parse(timestamp).strftime('%Y-%m-%d %H:%M:%S')
    )
  else
    OpenStruct.new
  end
end
