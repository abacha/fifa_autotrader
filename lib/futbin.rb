# frozen_string_literal: true

require 'rest-client'
require 'json'

class Futbin
  URL_BASE = 'https://www.futbin.com'
  PLATFORM = 'pc'

  def self.get_player_info(futbin_id)
    data = RestClient.get(
      "#{URL_BASE}/getPlayerInfo?type=full&id=#{futbin_id}&platform=#{PLATFORM}"
    )
    JSON.parse(data)
  end

  def self.get_player_avg_sell(resource_id)
    data = RestClient.get(
      "#{URL_BASE}/getPlayerAvgSell?days=1&resourceId=#{resource_id}&platform=#{PLATFORM}")
    JSON.parse(data)
  end
end
