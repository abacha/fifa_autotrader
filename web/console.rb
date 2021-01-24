require 'sinatra'
require_relative '../lib/manager'

get '/' do
  Manager.report.inspect
end
