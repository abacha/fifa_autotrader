# frozen_string_literal: true

class TransferTargetPage < BasePage
  PAGE_MENU_LINK = '.ut-tile-transfer-targets'

  def clear_expired
    click_on 'Transfers'
    find(PAGE_MENU_LINK).click

    if has_button?('Clear Expired')
      click_on 'Clear Expired'
      RobotLogger.msg('Expired bids cleared')
    end
  end

  def renew_bids
    market.refresh
    click_on 'Transfers'
    find(PAGE_MENU_LINK).click

    player_list = all('.has-auction-data.outbid')
    RobotLogger.msg("Renewing bids: #{player_list.count} outbid auctions")

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
        msg = find('.Notification.negative').text
        RobotLogger.log(:warn, { msg: msg })

        if msg.match(/Bid status changed, auction data will be updated/)
          market.refresh
          break
        end
      end

      sleep 6
    end
  end

  def list_bids
    click_on 'Transfers'
    find('.ut-tile-transfer-targets').click

    bids = all('.has-auction-data')

    msg = {
      'won': all('.has-auction-data.won').count,
      'highest-bidder': all('.has-auction-data.highest-bid').count,
      'outbid': all('.has-auction-data.outbid').count,
      'expired': all('.has-auction-data.expired').count,
      'total': bids.count
    }

    RobotLogger.msg("Active bids: #{msg}")

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
    RobotLogger.msg("Player listed to market: #{player.name} ($#{player.sell_value})")
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

      RobotLogger.msg(
        "Player bought: #{auction.player_name} ($#{auction.current_bid})")

      list_on_market(line, player)
      Trade.create!(auction.to_trade('B'))
    end
  end
end
