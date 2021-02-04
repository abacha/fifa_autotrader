class TradeMatcher
  def self.buy_trades
    Trade.where(matched: false, kind: 'B')
  end

  def self.sell_trades
    Trade.where(matched: false, kind: 'S')
  end


  def self.match_trades
    RobotLogger.log(:info, { action: 'match_trades', msg: 'Trades matched' })

    buy_trades.each do |buy_trade|
      sell_trade = sell_trades.where(player_name: buy_trade.player_name).first

      if buy_trade && sell_trade
        MatchedTrade.create!(buy_trade: buy_trade, sell_trade: sell_trade)
      end
    end
  end
end
