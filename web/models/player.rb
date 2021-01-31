# frozen_string_literal: true

require './lib/cache'
require './lib/futbin'

class Player < ActiveRecord::Base
  validates_presence_of :name, :fullname, :futbin_id, :sell_value, :max_bid, :status

  def self.actives
    where(status: 1)
  end

  def populate_resource_id
    data = Futbin.get_player_info(futbin_id)
    update_attributes(resource_id: data['resource'])
  end

  def stock
    Stock.by_player(name)
  end

  def futbin_market_data
    Cache.fetch("futbin_market_data_#{name}") do
      populate_resource_id unless resource_id
      Futbin.get_player_avg_sell(resource_id)
    end
  end
end
