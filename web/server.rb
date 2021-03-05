# frozen_string_literal: true

require './config/start.rb'

require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require 'action_view'
require 'ransack'
require 'will_paginate'
require 'will_paginate/active_record'
require 'will_paginate/view_helpers/sinatra'

include ActionView::Helpers::NumberHelper
include ActionView::Helpers::FormHelper
include ActionView::Helpers::FormOptionsHelper

Dir['./web/views/helpers/*'].sort.each { |klass| require klass }
Dir['./web/controllers/*'].sort.each { |klass| require klass }

def last_error
  image = Dir['web/public/screenshots/*.png'].max

  if image
    hash = image.match(%r{screenshots\/(.*?)\.})[1]
    img_path = image.gsub('web/public', '')
    timestamp = image.match(/\d{8}_\d{6}/)[0]
    error_msg = File.read("#{ENV['TMP_FOLDER']}/errors/#{hash}.log")

    OpenStruct.new(
      img_path: img_path, error_msg: error_msg,
      timestamp: DateTime.parse(timestamp).strftime('%Y-%m-%d %H:%M:%S')
    )
  else
    OpenStruct.new
  end
end
