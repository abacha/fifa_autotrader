require 'csv'
require 'awesome_print'
require 'singleton'
require 'forwardable'

require_relative '../features/business/stock.rb'
require_relative 'player_report.rb'


class Manager
  include Singleton
  extend Forwardable

  attr_reader :reports

  def self.calculate
    instance.calculate
  end

  def self.player(player_name)
    instance.reports[player_name]
  end

  def self.reports
    calculate
    instance.reports
  end


  def calculate
    @reports = {}
    players = Player.all.group_by(&:name)

    Trade.order(:timestamp).each do |trade|
      player = players[trade.player_name][0]
      @reports[trade.player_name] ||= PlayerReport.new(player)
      @reports[trade.player_name].add_trade(trade)
    end
  end
end
