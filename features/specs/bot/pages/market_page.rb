# frozen_string_literal: true

class MarketPage < BasePage
  MAX_STOCK = Setting.get('MAX_STOCK').to_i
  MAX_TIME_LEFT = Setting.get('MAX_TIME_LEFT').to_i

  def refresh
    RobotLogger.msg('Refreshing market')
    enter_page
    click_on 'Search'
    sleep 2
  end

  def buy_players
    PlayerTrade.actives.each do |player|
      next if player.stock >= MAX_STOCK

      cache_time =
        (Cache.read("MARKET_REFRESH_#{player.name}") || 2.hour.ago) -
        MAX_TIME_LEFT

      if cache_time && cache_time <= Time.now
        search_results.buy player
        sleep 4
      else
        timeleft = ChronicDuration.output((cache_time - Time.now).round)
        RobotLogger.msg("Skipping player #{player.name} for #{timeleft}")
      end
    end
  end

  def search(player, mode)
    enter_page
    click_on 'Reset'
    fill_input(find('.ut-player-search-control input'), player.fullname)
    player_text = player.fullname
    player_text += "\n#{player.rating}" if player.rating
    find('button', text: player_text).click

    fill_search_attribute(player, :quality)
    fill_search_attribute(player, :rarity)
    fill_search_attribute(player, :position)

    i = index_for(mode)
    all('.search-prices .price-filter input')[i].click
    all('.search-prices .price-filter input')[i].set player.max_bid
    click_on 'Search'
    all('.has-auction-data', wait: 5).count
  end

  def snipe_players
    PlayerSnipe.where(bought: 0).each do |player|
      search_results.snipe player
    end
  end

  private

  def fill_search_attribute(player, attr)
    player_attribute = player.send(attr)
    return unless player_attribute

    find('span', text: attr.upcase).click
    find('li', text: player_attribute, exact_text: true).click
  end

  def index_for(i)
    if i == :bid
      1
    elsif i == :bin
      3
    end
  end

  def search_results
    SearchResultsPage.new
  end

  def page_menu_link
    '.ut-tile-transfer-market'
  end
end
