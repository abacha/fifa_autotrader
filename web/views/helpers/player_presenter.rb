# frozen_string_literal: true

module PlayerPresenter
  def sell_price_ratio(player)
    futbin_market_data = player.futbin_market_data
    if futbin_market_data['avg_sell_price'].positive?
      (player.sell_value / futbin_market_data['avg_sell_price'].to_f * 100)
    end
  end

  def max_bid_ratio(player)
    futbin_market_data = player.futbin_market_data
    if futbin_market_data['avg_sell_price'].positive?
      (player.max_bid / futbin_market_data['avg_sell_price'].to_f * 100)
    end
  end
end
