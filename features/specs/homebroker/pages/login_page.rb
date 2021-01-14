# frozen_string_literal: true

require 'csv'
class LoginPage < BasePage
  def execute
    sleep 10
    login
    binding.pry
  end

  def login
    click_on 'Login'
    sleep 5
    fill_in 'email', with: 'abacha@gmail.com'
    fill_in 'password', with: 'psur_ept5tras9JUR'
    click_on 'Log In'
    click_on 'Send Security Code'
    security_code = 1
    binding.pry
    fill_in('oneTimeCode', with: security_code)
    click_on 'Log In'
    sleep 6
  end

  def process
    begin
      clear_bought
      clear_sold
      renew_bids
      market.buy_players
      active_bids
    rescue Selenium::WebDriver::Error::WebDriverError, Capybara::CapybaraError => e
      ElkLogger.log(:error, { msg: e.inspect })
      dialog = '.ui-dialog-type-alert'
      save_screenshot
      save_page


      if has_css?(dialog)
        dialog_text = find(dialog).text
        ElkLogger.log(:error, { dialog: dialog_text })
        if dialog_text.match(/BID TOO LOW/)
          click_on 'Ok'
        elsif dialog_text.match(/Unable to authenticate with the FUT servers/)
          exit
        elsif dialog_text.match(/NO INTERNET CONNECTION/)
          exit
        end
      else
        process
      end

    end
  end

  def load_cookies
    browser = Capybara.current_session.driver.browser.manage
    cookies = CSV.read('cookies.csv')
    cookies.each do |cookie|
      browser.add_cookie(
        name: cookie[0],
        value: cookie[1],
        path: cookie[2],
        domain: cookie[3],
        expires: DateTime.parse(cookie[4]),
        secure: cookie[5] == 'true'
      )
    end
  end

  def clear_bought
    ElkLogger.log(:info, { method: 'clear_bought' })
    click_on 'Transfers'
    clear_finished('B', '.ut-tile-transfer-targets')
  end

  def clear_sold
    ElkLogger.log(:info, { method: 'clear_sold' })
    click_on 'Transfers'
    clear_finished('S', '.ut-tile-transfer-list', 'Clear Sold')
    relist_players
  end

  def relist_players
    if has_css?('.has-auction-data.expired')
      ElkLogger.log(:info, { method: 'relist_players' })
      click_on 'Re-list All'
      click_on 'Yes'
    end
  end

  def transfer_list
    click_on 'Transfers'
    find('.ut-tile-transfer-list').click

    player_list = all('.has-auction-data')
    ElkLogger.log(:info, { kind: 'active selling', amount: player_list.count })
    # ElkLogger.log(:info, { kind: 'outbid', amount: all('.has-auction-data.outbid').count })
    # ElkLogger.log(:info, { kind: 'highest bid', amount: all('.has-auction-data.highest-bid').count })
  end

  def active_bids
    click_on 'Transfers'
    find('.ut-tile-transfer-targets').click

    player_list = all('.has-auction-data')
    ElkLogger.log(:info, { kind: 'active bids', amount: player_list.count })
    ElkLogger.log(:info, { kind: 'outbid', amount: all('.has-auction-data.outbid').count })
    ElkLogger.log(:info, { kind: 'highest bid', amount: all('.has-auction-data.highest-bid').count })

    player_list.each do |line|
      value_data = build(line, 'active')
      player = Player.find(value_data[:name])
      ElkLogger.log(:info, { name: player.name, bid: value_data[:current_bid], status: value_data[:status], timeleft: value_data[:timeleft] })
    end
    true
  end

  def renew_bids
    ElkLogger.log(:info, { method: 'renew_bids' })
    market.refresh
    click_on 'Transfers'
    find('.ut-tile-transfer-targets').click
    transaction_kind = 'outbid'

    player_list = all('.has-auction-data.outbid')
    ElkLogger.log(:info, { kind: transaction_kind, amount: player_list.count })

    click_on 'Clear Expired' if has_button?('Clear Expired')

    while has_css?('.has-auction-data.outbid')
      line = first('.has-auction-data.outbid')
      value_data = build(line, transaction_kind)
      player = Player.find(value_data[:name])

      next unless player

      line.click
      if value_data[:current_bid] < player.max_bid
        ElkLogger.log(:info, { name: player.name, bid: value_data[:current_bid], action: 'bid' })
        click_on 'Make Bid'
      else
        ElkLogger.log(:info, { name: player.name, bid: value_data[:current_bid], action: 'unwatch' })
        click_on 'Unwatch'
      end

      ElkLogger.log(:warn, { msg: find('.Notification.negative').text }) if has_css?('.Notification.negative')
    end
  end

  def build(line, transaction_kind)
    value_data = {
      timestamp: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
      kind: transaction_kind,
      name: line.find('.name').text,
      timeleft: line.find('.auction-state .time').text,
      status: line[:class].include?('outbid') ? 'outbid' : 'highest bid'
    }
    [:start_price, :current_bid, :buy_now].each_with_index do |item, i|
      value = line.all('.auctionValue')[i].find('.value').text.gsub(',', '')
      value_data[item] = value.to_i
    end
    value_data
  end

  def save_trade(value_data)
    CSV.open('players_trades.csv', 'a+') do |csv|
      csv << value_data.values_at(:timestamp,
                                  :kind,
                                  :name,
                                  :start_price,
                                  :current_bid,
                                  :buy_now)
    end
  end

  private
  def clear_finished(transaction_kind, menu, button_text = nil)
    click_on 'Transfers'
    find(menu).click

    player_list = all('.has-auction-data.won')
    ElkLogger.log(:info, { kind: transaction_kind, amount: player_list.count })

    player_list.each do |line|
      value_data = build(line, transaction_kind)
      player = Player.find(value_data[:name])
      save_trade(value_data) if player
      ElkLogger.log(:info, value_data )

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
    end
    click_on button_text if button_text && player_list.any?
  end

  def n(number)
    number.gsub(',', '').to_i
  end

  def loaded?
    !has_css?('.loaderIcon')
  end

  def market
    Market.new
  end
end
