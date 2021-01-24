require 'csv'
require 'awesome_print'
require_relative '../features/business/trade.rb'
require_relative '../features/business/player.rb'
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
    total = {stock: 0, profit: 0}
    @manager.reports.map do |player_name, player_report|
      report = player_report.report
      total[:stock] += report[:stock]
      total[:profit] += report[:profit]
      p report
    end
    p total
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
