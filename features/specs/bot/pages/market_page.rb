# frozen_string_literal: true

class MarketPage < BasePage
  PAGE_MENU_LINK = '.ut-tile-transfer-market'

  MAX_STOCK = Setting.get('MAX_STOCK').to_i
  MAX_TIME_LEFT = Setting.get('MAX_TIME_LEFT').to_i
  MAX_PLAYER_BIDS = Setting.get('MAX_PLAYER_BIDS').to_i

  def refresh
    RobotLogger.msg('Refreshing market')
    click_on 'Transfers'
    find('.ut-tile-transfer-market').click
    click_on 'Search'
    sleep 2
  end

  def buy_players
    Player.actives.each do |player|
      next if player.stock >= MAX_STOCK

      cache_time =
        (Cache.read("MARKET_REFRESH_#{player.name}") || 2.hour.ago) -
        MAX_TIME_LEFT

      if cache_time && cache_time <= Time.now
        buy_player player
        sleep 4
      else
        timeleft = ChronicDuration.output((cache_time - Time.now).round)
        RobotLogger.msg("Skipping player #{player.name} for #{timeleft}")
      end
    end
  end

  def search(player)
    click_on 'Transfers'
    find(PAGE_MENU_LINK).click
    fill_input('.ut-player-search-control input', player.fullname)
    click_on player.fullname
    if player.rarity
      find('span', text: 'RARITY').click
      find('li', text: player.rarity).click
    end
    all('.search-prices .price-filter input')[1].click
    all('.search-prices .price-filter input')[1].set player.max_bid
    click_on 'Search'
  end

  def buy_player(player)
    search(player)

    auctions = all('.has-auction-data').count
    RobotLogger.msg("Market search: #{player.name} with max. bid: #{player.max_bid} (hits: #{auctions})")
    0.upto([auctions, MAX_PLAYER_BIDS].min - 1) do |i|
      line = all('.has-auction-data')[i]

      next if line[:class].include? 'highest-bid'

      line.click
      sleep 2

      bid_value = n(find('.bidOptions input').value)
      text = all('.auctionInfo .subContent')[0].text
      timeleft = ChronicDuration.parse(text)

      if timeleft > MAX_TIME_LEFT
        RobotLogger.msg("Skipping player, min. time left: #{text}")
        Cache.write("MARKET_REFRESH_#{player.name}",
                    Time.now + [timeleft, 1.hour].min,
                    expires_in: 1.hour)
        break
      end

      next unless bid_value <= player.max_bid

      RobotLogger.msg(
        "Bidding on #{player.name} for $#{bid_value} (ETA: #{ChronicDuration.output(timeleft)})"
      )
      click_on 'Make Bid'
      sleep 3
    end
  end
end
