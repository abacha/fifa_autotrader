# frozen_string_literal: true

class SearchResultsPage < BasePage
  MAX_PLAYER_BIDS = Setting.get('MAX_PLAYER_BIDS').to_i
  MAX_TIME_LEFT = Setting.get('MAX_TIME_LEFT').to_i

  def snipe(player)
    return if player.bought == 1

    auctions_count = market.search(player, :bin)
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
          dialog_text = find('.Dialog .dialog-body').text
          confirm = dialog_text.match(/for (.*?) coins/)
          bin_value = text_to_number(confirm[1])
          RobotLogger.msg "Confirming snipe: $#{bin_value}"
          next if bin_value > player.max_bid
          sleep 3
          click_on 'Ok'
          msg = "Player sniped! #{player.name} for $#{auction.buy_now}"
          RobotLogger.msg(msg)
          Notification.send_all('Player Sniped', msg)
          break
        end
      end
    end
  end

  def buy(player)
    auctions_count = market.search(player, :bid)
    RobotLogger.msg("Market search: #{player.name} with max. bid: #{player.max_bid} (hits: #{auctions_count})")
    0.upto([auctions_count, MAX_PLAYER_BIDS].min - 1) do |i|
      line = all('.has-auction-data')[i]

      next if line[:class].include? 'highest-bid'

      line.click
      sleep 2

      bid_value = text_to_number(find('.bidOptions input').value)
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

  def market
    MarketPage.new
  end
end
