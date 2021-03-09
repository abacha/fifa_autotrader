# frozen_string_literal: true

class Trade < ActiveRecord::Base
  validates_presence_of :timestamp, :kind, :player_name, :start_price, :sold_for

  before_save :set_date
  after_destroy :destroy_matched_trade

  def set_date
    self.date = timestamp.to_date
  end

  def destroy_matched_trade
    matched_trade&.destroy
  end

  def matched_trade
    MatchedTrade.where('buy_trade_id = ? OR sell_trade_id = ?', id, id).first
  end
end
