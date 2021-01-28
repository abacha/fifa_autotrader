# frozen_string_literal: true

Player = Struct.new(:name, :fullname,
                    :max_bid, :sell_value, :status, :futbin_id, keyword_init: true) do
  def save
    PlayerRepository.update(self)
  end

  def stock
    Stock.by_player(name)
  end
end
