class ApplicationController < Sinatra::Base
  set :views, File.expand_path('../../views', __FILE__)

  not_found do
    title 'Not Found!'
    erb :not_found
  end
end
