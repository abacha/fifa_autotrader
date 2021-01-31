# frozen_string_literal: true

require 'yaml'
require_relative '../../lib/futbin'
require_relative 'player'

class PlayerRepository
  PLAYERS_FILE = 'players.yml'

  def self.all
    YAML.load(File.read(PLAYERS_FILE)).sort_by { |player| player.name }
  end

  def self.save(player)
    players = all.inject(Hash.new) { |h, e| h[e.name] = e; h }
    players[player.name] = player
    File.open(PLAYERS_FILE, 'w') { |file| file.write(players.values.to_yaml) }
  end

  def self.actives
    all.select { |player| player.status == '1' }
  end

  def self.find(player_name)
    all.detect { |player| player.name == player_name }
  end

  def self.populate_resource_id(player)
    data = Futbin.get_player_info(player.futbin_id)
    player.resource_id = data['resource']
    save(player)
  end
end
