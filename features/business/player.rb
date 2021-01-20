# frozen_string_literal: true

require 'csv'

Player = Struct.new(:name, :fullname,
                    :max_bid, :sell_value, :status, :id, keyword_init: true) do
  PLAYERS_FILE = 'players_buy.csv'

  def self.all
    CSV.read(PLAYERS_FILE).map do |line|
      Player.new(
        id: line[5],
        name: line[0],
        fullname: line[1],
        status: line[4],
        max_bid: line[2].to_i,
        sell_value: line[3].to_i
      )
    end
  end

  def self.update(player_updated)
    FileUtils.copy(PLAYERS_FILE, "#{PLAYERS_FILE}.bkp")
    players = Player.all

    File.open(PLAYERS_FILE, 'w') do |line|
      players.each do |player|
        player = player_updated if player.name == player_updated.name

        line.puts player.values.join(',')
      end
    end
  end

  def self.actives
    all.select { |player| player.status == '1' }
  end

  def self.find(player_name)
    Player.all.detect { |player| player.name == player_name }
  end

  def save
    Player.update(self)
  end
end
