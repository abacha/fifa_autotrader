# frozen_string_literal: true

class Player < ActiveRecord::Base
  validates_presence_of :name, :fullname, :futbin_id, :sell_value, :max_bid, :status

  def self.actives
    where(status: 1)
  end

  def populate_resource_id
    data = Futbin.get_player_info(futbin_id)
    update(resource_id: data['resource'])
  end

  def stock
    Stock.by_player(name)
  end

  def futbin_market_data
    Cache.fetch("futbin_market_data_#{name}") do
      populate_resource_id if resource_id.blank?
      Futbin.get_player_avg_sell(resource_id)
    end
  end
end
