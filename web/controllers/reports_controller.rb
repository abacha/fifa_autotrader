# frozen_string_literal: true

class ReportsController < ApplicationController
  get '/charts' do
    @q = MatchedTrade.ransack(params[:q])
    matched_trades = @q.result
    grouped = matched_trades.group(:date)
    @dates = grouped.pluck(:date).map(&:to_s)

    @daily_profit = grouped.sum(:profit).map { |k, v| [k.to_s, v] }
    @avg_profit = grouped.average(:profit).map { |k, v| [k.to_s, v] }

    @trades = Trade.ransack(params[:q]).result.group(:date, :kind).count.map { |k, v| [k[0].to_s, k[1], v] }

    @keys = ((Date.today - 7)..Date.today).to_a.map(&:to_s)
    @players = @keys.map do |date|
      matched_trades.where(date: date).group(:player_name).count
    end

    if params[:q]
      @player_report = PlayerReport.new(params[:q][:player_name_eq]).report
    end

    haml :'/reports/charts'
  end

  get '/players' do
    @reports = PlayerReport.all
    haml :'/reports/players'
  end
end
