# frozen_string_literal: true

class Player
  def self.find_by(search_query)
    PlayerTrade.find_by(search_query) || PlayerSnipe.find_by(search_query)
  end
end
