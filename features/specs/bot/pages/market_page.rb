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
        buy player
        sleep 4
      else
        timeleft = ChronicDuration.output((cache_time - Time.now).round)
        RobotLogger.msg("Skipping player #{player.name} for #{timeleft}")
      end
    end
  end

  def search(player, mode)
    click_on 'Transfers'
    find(PAGE_MENU_LINK).click
    click_on 'Reset'
    fill_input('.ut-player-search-control input', player.fullname)
    click_on player.fullname
    if player.rarity
      find('span', text: 'RARITY').click
      find('li', text: player.rarity, exact_text: true).click
    end

    if player.quality
      find('span', text: 'QUALITY').click
      find('li', text: player.quality, exact_text: true).click
    end
    i = index_for(mode)
    all('.search-prices .price-filter input')[i].click
    all('.search-prices .price-filter input')[i].set player.max_bid
    click_on 'Search'
    all('.has-auction-data', wait: 5).count
  end

  def snipe_players
    PlayerSnipe.where(bought: 0).each do |player|
      snipe player
    end
  end

  def snipe(player)
    return if player.bought == 1

    auctions_count = search(player, :bin)
    RobotLogger.msg("Market snipe: #{player.name} with max. bin: #{player.max_bid} (hits: #{auctions_count})")
    return if auctions_count == 0

    auctions = 0.upto(auctions_count - 1).map do |i|
      line = all('.has-auction-data')[i]
      Auction.build(line)
    end

    min_price = auctions.min { |a1, a2| a1.buy_now <=> a2.buy_now }.buy_now

    0.upto(auctions_count - 1).map do |i|
      line = all('.has-auction-data')[i]
      auction = Auction.build(line)

      if auction.buy_now <= min_price
        ActiveRecord::Base.transaction do
          player.update(bought: 1)
          line.click
          sleep 2
          click_on 'Buy Now'
          sleep 3
          click_on 'Ok'
          confirm = find('.Dialog .dialog-body').text.match(/for (\d+) coins/)
          break if confirm[1].to_i > player.max_bid
          RobotLogger.msg("Player sniped! #{player.name} for #{auction.buy_now}")
        end
      end
    end
  end

  def buy(player)
    auctions_count = search(player, :bid)
    RobotLogger.msg("Market search: #{player.name} with max. bid: #{player.max_bid} (hits: #{auctions_count})")
    0.upto([auctions_count, MAX_PLAYER_BIDS].min - 1) do |i|
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

  private

  def index_for(i)
    if i == :bid
      1
    elsif i == :bin
      3
    end
  end
end
