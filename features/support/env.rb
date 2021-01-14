# frozen_string_literal: true

require 'pry'
require 'capybara'
require 'capybara/cucumber'
require 'selenium-webdriver'
require 'json'

require_relative 'helpers.rb'

# rubocop:disable Style/MixinUsage
include Helpers
# rubocop:enable Style/MixinUsage
