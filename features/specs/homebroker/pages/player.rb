# frozen_string_literal: true

require 'csv'

Player = Struct.new(:name, :fullname, :active, :max_bid, :sell_value) do
  def self.all
    CSV.read('players_buy.csv').map do |line|
      Player.new(line[0], line[1], line[4] == '1', line[2].to_i, line[3].to_i)
    end
  end

  def self.actives
    all.select { |player| player.active }
  end

  def self.find(player_name)
    Player.all.detect { |player| player.name == player_name }
  end
end
