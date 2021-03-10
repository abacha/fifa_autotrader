# frozen_string_literal: true

module FormHelpers
  def players_list
    Player.all.map(&:name)
  end

  def kinds_list
    { 'Buy': 'B', 'Sell': 'S' }
  end
end
