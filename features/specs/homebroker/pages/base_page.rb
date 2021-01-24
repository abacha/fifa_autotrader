# frozen_string_literal: true

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
        binding.pry
        sleep 10
        page.refresh
        sleep 10
      elsif error_msg.match(/NO INTERNET CONNECTION/)
        exit
      end
    end
  end

  def clear_finished(transaction_kind, menu)
    click_on 'Transfers'
    find(menu).click

    auctions = all('.has-auction-data.won').count
    ElkLogger.log(:info, { kind: transaction_kind, amount: auctions })

    0.upto(auctions - 1) do |i|
      line = all('.has-auction-data.won')[i]
      next unless line

      bid = Bid.build(line)
      bid.kind = transaction_kind
      ElkLogger.log(:info, bid.to_h)

      player = Player.find(bid.name)
      next unless player

      if transaction_kind == 'B'
        list_on_transfer_market(line, player)
      #elsif transaction_kind == 'S'
      #  click_on 'Remove'
      end

      Trade.save(bid)
    end

    click_on 'Clear Sold' if transaction_kind == 'S' && auctions > 0
  end

  private

  def list_on_transfer_market(line, player)
    line.click
    click_on 'List on Transfer Market'
    panels = all('.panelActions.open .panelActionRow')
    panels[1].find('input').click
    panels[1].find('input').set player.sell_value
    panels[2].find('input').click
    panels[2].find('input').set player.sell_value + 100
    click_on 'List for Transfer'
    ElkLogger.log(:info, { action: 'listed',
                           player: player.name, sell_value: player.sell_value })
  end

  def fill_input(input, value)
    find(input).click
    find(input).set value
  end
end
