# frozen_string_literal: true

class TransferTargetPage < BasePage
  class MixedValueError < StandardError; end

  def page_menu_link
    '.ut-tile-transfer-targets'
  end

  def clear_expired
    enter_page

    if has_button?('Clear Expired')
      click_on 'Clear Expired'
      RobotLogger.msg('Expired bids cleared')
    end
  end

  def renew_bids
    market.refresh
    enter_page
    RobotLogger.msg('Renewing bids')

    while has_css?('.has-auction-data.outbid')
      line = first('.has-auction-data.outbid')
      begin
        line.click
        auction = Auction.build(line)
        player = Player.find_by(name: auction.player_name)
        unless player
          RobotLogger.msg("Player not found: #{auction.player_name}")
          next
        end

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
                                 max_bid: player.max_bid })

        handle_bid_status_changed if has_css?('.Notification.negative')
        sleep 3
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        next
      end
    end
  end

  def handle_bid_status_changed
    msg = find('.Notification.negative').text
    RobotLogger.log(:warn, { msg: msg })

    if msg.match(/Bid status changed, auction data will be updated/)
      click_on 'Compare Price'
      item = 'div.paginated-item-list.ut-pinned-list ul li.outbid'
      find(item).click if has_css?(item, wait: 50)
    end
  end

  def list_bids
    click_on 'Transfers'
    find('.ut-tile-transfer-targets').click
    msg = {
      'won': all('.has-auction-data.won').count,
      'highest-bidder': all('.has-auction-data.highest-bid').count,
      'outbid': all('.has-auction-data.outbid').count,
      'expired': all('.has-auction-data.expired').count,
      'total': all('.has-auction-data').count
    }
    RobotLogger.msg("Active bids: #{msg}")
    build_auctions
  end

  def clear_bought
    enter_page

    auctions = all('.has-auction-data.won').count
    RobotLogger.log(:info, { action: 'clear_bought', amount: auctions })
    while has_css?('.has-auction-data.won')
      begin
        line = first('.has-auction-data.won')
        line.click
        auction = Auction.build(line)
        player = Player.find_by(name: auction.player_name)
        next unless player

        RobotLogger.msg(
          "Player bought: #{auction.player_name} ($#{auction.current_bid})"
        )

        market_lister.list(player)

        Trade.create!(auction.to_trade('B'))
      rescue MarketListerPartial::MixedValueError => e
        RobotLogger.log(:error, e.message)
        next
      rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
        next
      end
    end
  end

  private

  def market_lister
    MarketListerPartial.new
  end
end
