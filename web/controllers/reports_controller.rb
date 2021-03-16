# frozen_string_literal: true

class ReportsController < ApplicationController
  get '/' do
    grouped = matched_trades.group(:date)
    @dates = grouped.pluck(:date).map(&:to_s)
    @trades = trades.group(:date, :kind).count.map do |key, value|
      [key[0].to_s, key[1], value]
    end

    @daily_profit = grouped.sum(:profit).map { |k, v| [k.to_s, v] }
    @keys = ((Date.today - 7)..Date.today).to_a.map(&:to_s)
    @players = @keys.map do |date|
      matched_trades.where(date: date).group(:player_name).count
    end

    if params[:q]
      @player_report = PlayerReport.new(params[:q][:player_name_eq]).report
    else
      @player_report = PlayerReport.all
    end

    haml :'/reports/index'
  end

  private

  def matched_trades
    @matched_trades ||=
      begin
        @q = MatchedTrade.ransack(params[:q])
        matched_trades = @q.result
      end
  end

  def trades
    @trades ||=
      begin
        @q = Trade.ransack(params[:q])
        @q.result
      end
  end
end
