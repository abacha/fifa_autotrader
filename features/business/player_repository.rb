# frozen_string_literal: true

require 'yaml'

class PlayerRepository
  PLAYERS_FILE = 'players.yml'

  def self.all
    YAML.load(File.read(PLAYERS_FILE))
  end

  def self.update(player_updated)
    players = all.inject(Hash.new) { |h, e| h[e.name] = e; h }
    players[player_updated.name] = player_updated
    File.open(PLAYERS_FILE, 'w') { |file| file.write(players.values.to_yaml) }
  end

  def self.actives
    all.select { |player| player.status == '1' }
  end

  def self.find(player_name)
    all.detect { |player| player.name == player_name }
  end
end

