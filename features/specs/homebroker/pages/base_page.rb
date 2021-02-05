# frozen_string_literal: true

require './config/start.rb'

class BasePage
  include Capybara::DSL

  def go
    raise NotImplementedError unless respond_to?(:execute)

    begin
      send(:execute)
    rescue StandardError => e
      raise e
    end
  end

  def n(number)
    number.gsub(',', '').to_i
  end

  private
  def market
    @market ||= MarketPage.new
  end

  def transfer_list
    @transfer_list ||= TransferListPage.new
  end

  def transfer_target
    @transfer_target ||= TransferTargetPage.new
  end

  def login
    @login ||= LoginPage.new
  end

  def fill_input(input, value)
    find(input).click
    sleep 0.5
    find(input).set value
  end
end
