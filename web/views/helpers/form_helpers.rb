# frozen_string_literal: true

helpers do
  def players_list
    Player.all.map(&:name)
  end

  def kinds_list
    { 'Buy': 'B', 'Sell': 'S' }
  end
end
