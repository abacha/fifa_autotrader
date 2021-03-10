class ApplicationController < Sinatra::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  helpers WillPaginate::Sinatra::Helpers

  set :static, true
  set :public, './web/public'


  Dir.glob('./web/views/helpers/*.rb').each do |helper|
    require helper
    klass = helper.match(/(\w+)\.rb/)[1]
    helpers eval(klass.camelize)
  end

  set :views, File.expand_path('../../views', __FILE__)
end
