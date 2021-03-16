# frozen_string_literal: true

require 'rest-client'
require 'json'

class Futbin
  URL_BASE = 'https://www.futbin.com'
  FIFA_PLATFORM = Setting.get('FIFA_PLATFORM').downcase

  def self.get_player_info(futbin_id)
    url =
      "#{URL_BASE}/getPlayerInfo?type=full&id=#{futbin_id}&platform=#{FIFA_PLATFORM}"
    fetch_json(url)
  end

  def self.get_player_avg_sell(resource_id)
    url =
      "#{URL_BASE}/getPlayerAvgSell?days=1&resourceId=#{resource_id}&platform=#{FIFA_PLATFORM}"
    data = fetch_json(url)
    {
      'avg_sell_price' => data['avg_sell_price'].to_i,
      'sell_rate' => (data['sell_rate'] * 100).to_i
    }
  end

  def self.market_data
    graph_type = 'live_graph' || 'daily_graph' || 'today'
    index = 'Gold'

    url = "#{URL_BASE}/marketGraph?type=#{graph_type}&console=#{FIFA_PLATFORM.upcase}&indexversion=#{index}"
    fetch_json(url)
  end

  def self.fetch_json(url)
    data = RestClient.get(url)
    JSON.parse(data)
  end
end
