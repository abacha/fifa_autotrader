# frozen_string_literal: true

class Trade < ActiveRecord::Base
  validates_presence_of :timestamp, :kind, :player_name, :start_price, :sold_for

  before_save :set_date
  def set_date
    self.date = timestamp.to_date
  end
end
