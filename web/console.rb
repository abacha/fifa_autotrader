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
  @trades = Trade.all.reverse
  haml :index
end

get '/trades' do
  @trades = Trade.all.reverse
  haml :trades
end
