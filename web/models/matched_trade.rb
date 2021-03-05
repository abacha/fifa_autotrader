# frozen_string_literal: true

class MatchedTrade < ActiveRecord::Base
  EA_TAX = Setting.get('EA_TAX').to_f

  belongs_to :buy_trade, class_name: 'Trade', foreign_key: 'buy_trade_id'
  belongs_to :sell_trade, class_name: 'Trade', foreign_key: 'sell_trade_id'

  validates_presence_of :buy_trade_id, :sell_trade_id
  validate :trade_players

  before_save :calculate_profit
  before_save :calculate_duration
  before_save :set_timestamp
  before_save :set_player_name
  after_save :mark_matched_trades
  after_destroy :unmatch_trades

  def unmatch_trades
    buy_trade&.update(matched: 0)
    sell_trade&.update(matched: 0)
  end

  def trade_players
    errors.add(:sell_trade_id, 'trade players are different') if buy_trade.player_name != sell_trade.player_name
  end

  def calculate_profit
    self.profit =
      -buy_trade.sold_for + (sell_trade.sold_for * (1 - EA_TAX))
  end

  def calculate_duration
    self.duration = sell_trade.timestamp - buy_trade.timestamp
  end

  def set_player_name
    self.player_name = sell_trade.player_name
  end

  def set_timestamp
    self.timestamp = sell_trade.timestamp
    self.date = DateTime.strptime(timestamp.to_s, '%s')
  end

  def mark_matched_trades
    sell_trade.update(matched: true)
    buy_trade.update(matched: true)
  end
end
