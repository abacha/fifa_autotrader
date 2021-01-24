# frozen_string_literal: true

class MarketPage < BasePage
  MAX_STOCK = 5
  MAX_TIME_LEFT = 600
  MAX_PLAYER_BIDS = 5

  def refresh
    ElkLogger.log(:info, { method: 'refresh_market' })
    click_on 'Transfers'
    find('.ut-tile-transfer-market').click
    click_on 'Search'
    sleep 2
    ElkLogger.log(:info, { msg: 'Market refreshed' })
  end

  def buy_players
    ElkLogger.log(:info, { method: 'buy_players' })
    Player.actives.each do |player|
      buy_player player.name # && player.stock < MAX_STOCK
      sleep 10
    end
  end

  def buy_player(player_name)
    player = Player.find(player_name)
    click_on 'Transfers'
    find('.ut-tile-transfer-market').click

    fill_input('.ut-player-search-control input', player.fullname)
    click_on player.fullname

    all('.search-prices .price-filter input')[1].click
    all('.search-prices .price-filter input')[1].set player.max_bid
    click_on 'Search'

    auctions = all('.has-auction-data').count
    ElkLogger.log(:info, { search: player_name, count: auctions })
    0.upto([auctions, MAX_PLAYER_BIDS].min - 1) do |i|
      line = all('.has-auction-data')[i]

      binding.pry if line.nil?
      next if line[:class].include? 'highest-bid'

      line.click
      sleep 2

      bid_value = n(find('.bidOptions input').value)
      timeleft = ChronicDuration.parse(all('.auctionInfo .subContent')[0].text)

      if bid_value <= player.max_bid && timeleft < MAX_TIME_LEFT
        ElkLogger.log(:info, { action: 'bid',
                               bid_value: bid_value,
                               player: player.name,
                               timeleft: timeleft })
        click_on 'Make Bid'

        sleep 3
      end
    end
  end
end
