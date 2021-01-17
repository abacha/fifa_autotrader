# frozen_string_literal: true

class TransferTargetPage < BasePage
  def clear
    ElkLogger.log(:info, { method: 'clear_bought' })
    click_on 'Transfers'
    clear_finished('B', '.ut-tile-transfer-targets')
  end

  def renew_bids
    ElkLogger.log(:info, { method: 'renew_bids' })
    market.refresh
    click_on 'Transfers'
    find('.ut-tile-transfer-targets').click
    transaction_kind = 'outbid'

    player_list = all('.has-auction-data.outbid')
    ElkLogger.log(:info, { kind: transaction_kind, amount: player_list.count })

    while has_css?('.has-auction-data.outbid')
      line = first('.has-auction-data.outbid')
      value_data = Bid.build(line, transaction_kind)
      player = Player.find(value_data[:name])

      next unless player

      line.click
      if value_data[:current_bid] < player.max_bid
        ElkLogger.log(:info, { name: player.name,
                               bid: value_data[:current_bid],
                               action: 'bid' })

        click_on 'Make Bid'
      else
        ElkLogger.log(:info, { name: player.name,
                               bid: value_data[:current_bid],
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
    ElkLogger.log(:info, { action: 'bids', amount: player_list.count })

    ElkLogger.log(:info, { action: 'bids', kind: 'outbid',
                           amount: all('.has-auction-data.outbid').count })
    ElkLogger.log(:info, { action: 'bids', kind: 'highest bid',
                           amount: all('.has-auction-data.highest-bid').count })
    ElkLogger.log(:info, { action: 'bids', kind: 'won',
                           amount: all('.has-auction-data.won').count })

    player_list.map do |line|
      value_data = Bid.build(line, 'active')
      player = Player.find(value_data[:name])

      {
        name: value_data[:name],
        bid: value_data[:current_bid],
        status: value_data[:status],
        timeleft: value_data[:timeleft]
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
