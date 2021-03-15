# frozen_string_literal: true

class PlayerReport
  attr_reader :player, :trades

  def self.all
    Player.all.map { |player| new(player.name).report }
  end

  def initialize(player_name, filter = {})
    @player = Player.find_by(name: player_name)
    @trades = Trade.where(filter.merge(player_name: player_name))
  end

  def report
    OpenStruct.new({
                     total: matched_trades.count,
                     stock: stock,
                     profit: profit,
                     avg_profit: avg_profit,
                     avg_duration: avg_duration,
                     avg_buy_price: avg_buy_price,
                     avg_sell_price: avg_sell_price,
                     player: player,
                     last_trade: matched_trades.last
                   })
  end

  def matched_trades
    trade_ids = trades.pluck(:id)
    @matched_trades ||=
      MatchedTrade.where(buy_trade_id: trade_ids).
      or(MatchedTrade.where(sell_trade_id: trade_ids))
  end

  def total(kind)
    trades.where(kind: kind).sum(:sold_for)
  end

  def amount(kind)
    trades.where(kind: kind).count
  end

  def profit
    matched_trades.sum(:profit) +
      trades.where(kind: 'B', matched: 0).sum(:sold_for)
  end

  def avg_profit
    profit / amount('S')
  rescue ZeroDivisionError
    0
  end

  def avg_duration
    buy_trades = trades.where(kind: 'B', matched: 0).map do |trade|
      Time.now - trade.timestamp
    end

    ((matched_trades.sum(:duration) + buy_trades.sum) /
      (amount('S') + buy_trades.size)).to_i
  rescue ZeroDivisionError
    0
  end

  def stock
    Stock.by_player(player.name)
  end

  def avg_buy_price
    total('B') / amount('B')
  rescue ZeroDivisionError
    0
  end

  def avg_sell_price
    total('S') / amount('S')
  rescue ZeroDivisionError
    0
  end
end
