# frozen_string_literal: true

class TransferTargetPage < BasePage
  def clear
    RobotLogger.log(:info, { method: 'clear_bought' })
    click_on 'Transfers'
    clear_finished('B', '.ut-tile-transfer-targets')
  end

  def renew_bids
    RobotLogger.log(:info, { method: 'renew_bids' })
    market.refresh
    click_on 'Transfers'
    find('.ut-tile-transfer-targets').click
    transaction_kind = 'outbid'

    player_list = all('.has-auction-data.outbid')
    RobotLogger.log(:info, { kind: transaction_kind, amount: player_list.count })

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
      else
        RobotLogger.log(:info, { name: player.name,
                               bid: auction.current_bid,
                               action: 'unwatch' })

        click_on 'Unwatch'
      end

      if has_css?('.Notification.negative')
        raise Capybara::CapybaraError.new(find('.Notification.negative').text)
      end

      sleep 6
    end
  end

  def list
    click_on 'Transfers'
    find('.ut-tile-transfer-targets').click

    player_list = all('.has-auction-data')

    RobotLogger.log(:info, { action: 'bids',
                           total: player_list.count,
                           outbid: all('.has-auction-data.outbid').count,
                           'highest-bid': all('.has-auction-data.highest-bid').count,
                           won: all('.has-auction-data.won').count })

    player_list.map do |line|
      auction = Auction.build(line)
      player = PlayerRepository.find(auction[:name])

      {
        name: auction[:name],
        bid: auction[:current_bid],
        status: auction[:status],
        timeleft: auction[:timeleft]
      }
    end
  end

  def clear_expired
    click_on 'Clear Expired' if has_button?('Clear Expired')
  end

  private

  def market
    MarketPage.new
  end
end
