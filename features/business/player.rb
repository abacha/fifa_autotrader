# frozen_string_literal: true

require_relative '../../lib/cache'

Player = Struct.new(:name, :fullname, :max_bid, :sell_value,
                    :status, :futbin_id, :resource_id, keyword_init: true) do
  def save
    PlayerRepository.update(self)
  end

  def stock
    Stock.by_player(name)
  end


  def futbin_market_data
    Cache.fetch("futbin_market_data_#{name}") do
      PlayerRepository.populate_resource_id(self) unless resource_id
      Futbin.get_player_avg_sell(resource_id)
    end
  end
end
