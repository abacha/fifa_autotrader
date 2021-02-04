# frozen_string_literal: true

class TransferTargetPage < BasePage
  PAGE_MENU_LINK = '.ut-tile-transfer-targets'

  def clear_expired
    click_on 'Transfers'
    find(PAGE_MENU_LINK).click

    if has_button?('Clear Expired')
      click_on 'Clear Expired'
      RobotLogger.log(:info, { action: 'clear_expired', msg: 'Expired bids cleared' })
    end
  end

  def renew_bids
    market.refresh
    click_on 'Transfers'
    find(PAGE_MENU_LINK).click

    player_list = all('.has-auction-data.outbid')
    RobotLogger.log(:info, { action: 'renew_bids', amount: player_list.count })

    while has_css?('.has-auction-data.outbid')
      line = first('.has-auction-data.outbid')
      line.click

      auction = Auction.build(line)
      player = Player.find_by(name: auction.player_name)

      next unless player

      action =
        if auction[:current_bid] < player.max_bid
          click_on 'Make Bid'
          'bid'
        else
          click_on 'Unwatch'
          'unwatch'
        end

      RobotLogger.log(:info, { action: action,
                               name: player.name,
                               current_bid: auction.current_bid,
                               max_bid: player.max_bid  })

      if has_css?('.Notification.negative')
        RobotLogger.log(:warn, { msg: find('.Notification.negative').text })
      end

      sleep 6
    end
  end

  def list_bids
    click_on 'Transfers'
    find('.ut-tile-transfer-targets').click

    bids = all('.has-auction-data')

    RobotLogger.log(:info, { action: 'list_bids',
                           total: bids.count,
                           outbid: all('.has-auction-data.outbid').count,
                           expired: all('.has-auction-data.expired').count,
                           'highest-bid': all('.has-auction-data.highest-bid').count,
                           won: all('.has-auction-data.won').count })

    bids.map { |line| Auction.build(line) }
  end

  def list_on_market(line, player)
    line.click
    sleep 2
    click_on 'List on Transfer Market'
    panels = all('.panelActions.open .panelActionRow')
    panels[1].find('input').click
    panels[1].find('input').set player.sell_value
    panels[2].find('input').click
    panels[2].find('input').set player.sell_value + 100
    click_on 'List for Transfer'
    RobotLogger.log(:info, { msg: 'Player listed to market',
                           player: player.name, sell_value: player.sell_value })
  end

  def clear_bought
    click_on 'Transfers'
    find('.ut-tile-transfer-targets').click

    auctions = all('.has-auction-data.won').count
    RobotLogger.log(:info, { action: 'clear_bought', amount: auctions })

    0.upto(auctions - 1) do |i|
      line = all('.has-auction-data.won')[i]
      next unless line

      auction = Auction.build(line)

      player = Player.find_by(name: auction.player_name)
      next unless player

      list_on_market(line, player)
      trade = Trade.create!(auction.to_trade('B'))
      RobotLogger.log(:info, msg: 'Player Bought!',
                      player: trade.player_name, sell_value: trade.sold_for)
    end
  end

  private

  def market
    MarketPage.new
  end
end
