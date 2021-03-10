require './config/start'
require 'sinatra/base'
require 'sinatra/reloader'
require 'haml'
require 'action_view'
require 'ransack'
require 'will_paginate'
require 'will_paginate/active_record'
require 'will_paginate/view_helpers/sinatra'

Dir.glob('./web/controllers/*.rb').sort.each do |controller|
  require controller

  route = controller.match(/(\w+)_controller/)[1]
  map("/#{route}") { run eval("#{route.camelize}Controller") }
end

run DashboardController
