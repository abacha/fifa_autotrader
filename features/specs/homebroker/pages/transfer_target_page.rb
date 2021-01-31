# frozen_string_literal: true

class TransferTargetPage < BasePage
  PAGE_MENU_LINK = '.ut-tile-transfer-targets'

  def clear_expired
    click_on 'Transfers'
    find(PAGE_MENU_LINK).click

    if has_button?('Clear Expired')
      click_on 'Clear Expired'
      RobotLogger.log(:info, { action: 'clear_expired' })
    end
  end

  def renew_bids
    market.refresh
    click_on 'Transfers'
    find(PAGE_MENU_LINK).click
    transaction_kind = 'outbid'

    player_list = all('.has-auction-data.outbid')
    RobotLogger.log(:info, { action: 'renew_bids', amount: player_list.count })

    while has_css?('.has-auction-data.outbid')
      line = first('.has-auction-data.outbid')
      auction = Auction.build(line)
      player = PlayerRepository.find(auction[:name])

      next unless player

      line.click
      sleep 2
      if auction[:current_bid] < player.max_bid
        RobotLogger.log(:info, { name: player.name,
                               bid: auction.current_bid,
                               action: 'bid' })

        click_on 'Make Bid'
      #else
      #  RobotLogger.log(:info, { name: player.name,
      #                         bid: auction.current_bid,
      #                         action: 'unwatch' })
      #  click_on 'Unwatch'
      end

      if has_css?('.Notification.negative')
        raise Capybara::CapybaraError.new(find('.Notification.negative').text)
      end

      sleep 6
    end
  end

  def list_bids
    click_on 'Transfers'
    find('.ut-tile-transfer-targets').click

    player_list = all('.has-auction-data')

    RobotLogger.log(:info, { action: 'list_bids',
                           total: player_list.count,
                           outbid: all('.has-auction-data.outbid').count,
                           'highest-bid': all('.has-auction-data.highest-bid').count,
                           won: all('.has-auction-data.won').count })

    player_list.map do |line|
      auction = Auction.build(line)

      {
        name: auction[:name],
        bid: auction[:current_bid],
        status: auction[:status],
        timeleft: auction[:timeleft]
      }
    end
  end

  def list_on_market(line, player)
    line.click
    click_on 'List on Transfer Market'
    panels = all('.panelActions.open .panelActionRow')
    panels[1].find('input').click
    panels[1].find('input').set player.sell_value
    panels[2].find('input').click
    panels[2].find('input').set player.sell_value + 100
    click_on 'List for Transfer'
    RobotLogger.log(:info, { action: 'list_on_market',
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
      auction.kind = 'B'
      RobotLogger.log(:info, auction.to_h)

      player = PlayerRepository.find(auction.name)
      next unless player
      list_on_market(line, player)
      Trade.save(auction)
    end
  end

  private

  def market
    MarketPage.new
  end
end
