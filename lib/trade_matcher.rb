class TradeMatcher
  def self.buy_trades
    Trade.where(matched: false, kind: 'B').order(:timestamp)
  end

  def self.sell_trades
    Trade.where(matched: false, kind: 'S').order(:timestamp)
  end


  def self.match_trades
    buy_trades.each do |buy_trade|
      sell_trade = sell_trades.where(
        'player_name = ? AND timestamp > ?', buy_trade.player_name, buy_trade.timestamp).first

      if buy_trade && sell_trade
        MatchedTrade.create!(buy_trade: buy_trade, sell_trade: sell_trade)
      end
    end
  end
end
