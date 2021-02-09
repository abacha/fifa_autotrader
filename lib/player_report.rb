class PlayerReport
  attr_reader :player, :trades

  def self.all
    Player.all.map { |player| new(player).report }
  end

  def initialize(player, filter = {})
    @player = player
    @trades = Trade.where(filter.merge(player_name: player.name))
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
      player: player
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
  rescue
    0
  end

  def avg_duration
    buy_trades = trades.where(kind: 'B', matched: 0).map do |trade|
      Time.now - trade.timestamp
    end

    ((matched_trades.sum(:duration) + buy_trades.sum) /
      (amount('S') + buy_trades.size)).to_i
  rescue
    0
  end

  def stock
    amount('B') - amount('S')
  end

  def avg_buy_price
    total('B') / amount('B')
  rescue
    0
  end

  def avg_sell_price
    total('S') / amount('S')
  rescue
    0
  end
end
