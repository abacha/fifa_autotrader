# frozen_string_literal: true

require 'csv'
class BasePage
  include Capybara::DSL

  def page_name
    self.class.name
  end

  def go
    raise NotImplementedError unless respond_to?(:execute)

    log('Iniciando')
    begin
      send(:execute)
      log('Finalizando')
    rescue StandardError => e
      log('Erro')
      raise e
    end
  end

  def log(msg)
    ElkLogger.log(:debug, page_name: page_name, message: msg)
  end

  def n(number)
    number.gsub(',', '').to_i
  end

  def loaded?
    !has_css?('.loaderIcon')
  end

  def do_process(&block)
    begin
      block.call
    rescue Selenium::WebDriver::Error::WebDriverError, Capybara::CapybaraError => e
      ElkLogger.log(:error, { msg: e.inspect })
      error_msg = e.message
      dialog = '.ui-dialog-type-alert'
      save_screenshot
      save_page

      if has_css?(dialog)
        error_msg = find(dialog).text
        ElkLogger.log(:error, { dialog: error_msg })
      end

      if error_msg.match(/BID TOO LOW/)
        click_on 'Ok'
      elsif error_msg.match(/Unable to authenticate with the FUT servers/)
        exit
      elsif error_msg.match(/VERIFICATION REQUIRED/)
        exit
      elsif error_msg.match(/NO INTERNET CONNECTION/)
        exit
      end
    end
  end

  def clear_finished(transaction_kind, menu, button_text = nil)
    click_on 'Transfers'
    find(menu).click

    player_list = all('.has-auction-data.won')
    ElkLogger.log(:info, { kind: transaction_kind, amount: player_list.count })

    player_list.each do |line|
      bid = Bid.build(line, transaction_kind)
      player = Player.find(bid.name)
      ElkLogger.log(:info, bid.to_h)

      if transaction_kind == 'B' && player.name
        line.click
        click_on 'List on Transfer Market'
        panels = all('.panelActions.open .panelActionRow')
        panels[1].find('input').click
        panels[1].find('input').set player.sell_value
        panels[2].find('input').click
        panels[2].find('input').set player.sell_value + 100
        click_on 'List for Transfer'
        ElkLogger.log(:info, { action: 'listed', player: player.name, sell_value: player.sell_value })
      end

      Trade.save(bid) if player
    end
    click_on button_text if button_text && player_list.any?
  end

  def fill_input(input, value)
    find(input).click
    find(input).set value
  end
end
