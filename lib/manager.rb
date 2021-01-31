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

  def self.match_trades
		result = []
		stock = []
		trades = Trade.all
		while trades.any?
			buy_trade = trades.detect { |t| t.kind == 'B' }
			sell_trade = trades.detect { |t| t.kind == 'S' && t.player_name == buy_trade.player_name }
			trades.delete_at(trades.index(buy_trade))
			if !sell_trade
				stock << buy_trade
				next
			end
			trades.delete_at(trades.index(sell_trade))
			result << {
				player_name: buy_trade.player_name,
				buy_time: buy_trade.timestamp,
				sell_time: sell_trade.timestamp,
				buy_value: buy_trade.sold_for,
				sell_value: sell_trade.sold_for,
				profit: -buy_trade.sold_for + (sell_trade.sold_for * (1-0.05))
			}
		end
		[result, stock]
  end

  def calculate
    @reports = {}
    players = Player.all.group_by(&:name)

    Trade.all.each do |trade|
      player = players[trade.player_name][0]
      @reports[trade.player_name] ||= PlayerReport.new(player)
      @reports[trade.player_name].add_trade(trade)
    end
  end
end
