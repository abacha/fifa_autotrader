# frozen_string_literal: true

class MarketPage < BasePage
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
    Player.all.each do |player|
      buy_player player.name if player.active
      sleep 10
    end
  end

  def buy_player(player_name)
    ElkLogger.log(:info, { search: player_name })
    player = Player.find(player_name)
    click_on 'Transfers'
    find('.ut-tile-transfer-market').click

    fill_input('.ut-player-search-control input', player.fullname)
    click_on player.fullname

    all('.search-prices .price-filter input')[1].click
    all('.search-prices .price-filter input')[1].set player.max_bid
    click_on 'Search'

    players_list = all('.has-auction-data:not(.highest-bid)')
    ElkLogger.log(:info, { search_result: player_name, count: players_list.count })
    players_list[0..5].each do |line|
      line.click
      sleep 2
      bid_value = n(find('.bidOptions input').value)
      timeleft = ChronicDuration.parse(all('.auctionInfo .subContent')[0].text)

      if bid_value <= player.max_bid && timeleft < 600
        ElkLogger.log(:info, { action: 'bid', bid_value: bid_value, player: player.name, timeleft: timeleft })
        click_on 'Make Bid'
      end
      sleep 6
    end
  end

  private

  def fill_input(input, value)
    find(input).click
    find(input).set value
  end

  def n(number)
    number.gsub(',', '').to_i
  end
end
