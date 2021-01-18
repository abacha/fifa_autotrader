require 'csv'
require 'awesome_print'
require_relative '../features/specs/homebroker/pages/trade.rb'
require_relative '../features/specs/homebroker/pages/player.rb'
require_relative 'player_report.rb'


class Manager
  attr_reader :reports

  def self.calculate
    @manager ||= Manager.new
    @manager.calculate
  end

  def self.player(player_name)
    @manager.reports[player_name]
  end

  def self.report
    calculate
    Player.all.map do |player|
      player(player.name).report if player(player.name)
    end
  end

  def calculate
    @reports = {}

    Trade.all.each do |trade|
      player_name = trade.player_name
      @reports[player_name] ||= PlayerReport.new(player_name)
      @reports[player_name].add_trade(trade)
    end
  end
end
