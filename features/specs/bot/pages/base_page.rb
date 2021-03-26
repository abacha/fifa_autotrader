# frozen_string_literal: true

require './config/start'

class BasePage
  include Capybara::DSL

  def go
    raise NotImplementedError unless defined?(execute)

    begin
      send(:execute)
    rescue StandardError => e
      raise e
    end
  end

  def enter_page
    raise NotImplementedError unless defined?(page_menu_link)

    click_on 'Transfers'
    find(page_menu_link).click
  end

  def text_to_number(number)
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

  def build_auctions(selector = '')
    selector = ".#{selector}" unless selector.blank?
    selector = ".has-auction-data#{selector}"
    auctions_list = all(selector)
    auctions_list.map { |line| Auction.build(line) }
  end

  def fill_input(input, value)
    input.click
    sleep 0.5
    input.set value
  end
end
