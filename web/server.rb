# frozen_string_literal: true

require './config/start'

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
