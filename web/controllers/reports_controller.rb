# frozen_string_literal: true

class ReportsController < ApplicationController
  get '/' do
    haml :'/reports/index'
  end

  get '/chart_data' do
    grouped = matched_trades.group(:date)
    dates = grouped.pluck(:date).map(&:to_s)
    grouped_trades = trades.group(:date, :kind).count.map do |key, value|
      [key[0].to_s, key[1], value]
    end
    daily_profit = grouped.sum(:profit).map { |k, v| [k.to_s, v] }

    json({
      matched_trades_count: matched_trades.count,
      params: params,
      dates: dates,
      daily_profit: daily_profit,
      trades: grouped_trades
    })
  end

  get '/players' do
    params[:q] ||= {}
    filters = params[:q][:date_gteq] ?
      "date > '#{params[:q][:date_gteq]}' AND date <= '#{params[:q][:date_lteq]}'" : ''

    puts filters
    @player_report = if params[:q][:player_name_eq].blank?
      PlayerReport.all(filters)
    else
      PlayerReport.new(params[:q][:player_name_eq], filters)
    end

    haml :'/reports/_player_report', layout: false
  end

  private

  def matched_trades
    MatchedTrade.ransack(params[:q]).result
  end

  def trades
    Trade.ransack(params[:q]).result
  end
end
