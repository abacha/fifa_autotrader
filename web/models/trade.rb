class Trade < ActiveRecord::Base
  validates_presence_of :timestamp, :kind, :player_name, :start_price, :sold_for
end
