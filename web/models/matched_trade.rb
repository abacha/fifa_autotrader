class MatchedTrade < ActiveRecord::Base
  belongs_to :buy_trade, class_name: 'Trade', foreign_key: 'buy_trade_id'
  belongs_to :sell_trade, class_name: 'Trade', foreign_key: 'sell_trade_id'

  validates_presence_of :buy_trade_id, :sell_trade_id
  validate :trade_players

  before_save :calculate_profit
  before_save :calculate_duration
  before_save :set_timestamp
  before_save :set_player_name
  after_save :mark_matched_trades

  def trade_players
    if buy_trade.player_name != sell_trade.player_name
      errors.add(:sell_trade_id, 'trade players are different')
    end
  end

  def calculate_profit
    self.profit =
      -buy_trade.sold_for + (sell_trade.sold_for * (1-ENV['EA_TAX'].to_f))
  end

  def calculate_duration
    self.duration = sell_trade.timestamp - buy_trade.timestamp
  end

  def set_player_name
    self.player_name = sell_trade.player_name
  end

  def set_timestamp
    self.timestamp = sell_trade.timestamp
  end

  def mark_matched_trades
    sell_trade.update(matched: true)
    buy_trade.update(matched: true)
  end
end
