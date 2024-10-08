# frozen_string_literal: true

class PlayerTrade < ActiveRecord::Base
  RARITY_FILE = ENV['RARITY_FILE']

  validates :name, :fullname, :futbin_id, :sell_value, :max_bid, presence: true
  validate :check_rarity

  def self.actives
    where(status: 1)
  end

  def rarities
    YAML.safe_load(File.read(RARITY_FILE))
  end

  def check_rarity
    errors.add(:rarity, :invalid) if rarity && !rarities.include?(rarity)
  end

  def populate_resource_id
    data = Futbin.get_player_info(futbin_id)
    update(resource_id: data['resource'])
  end

  def optimize_value
    futbin_value = futbin_market_data['avg_sell_price']
    data = TradeOptimizer.values(futbin_value)
    update(max_bid: data[:max_bid], sell_value: data[:sell_value])
  end

  def stock
    Trade.where(player_name: name, kind: 'B', matched: 0).count
  end

  def futbin_market_data
    Cache.fetch(cache_key) do
      populate_resource_id if resource_id.blank?
      Futbin.get_player_avg_sell(resource_id)
    end
  end

  def cache_key
    "futbin_market_data_#{name}"
  end
end
