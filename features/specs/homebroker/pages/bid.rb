# frozen_string_literal: true

Bid = Struct.new(:timestamp, :kind, :name,
                 :timeleft, :status, :start_price,
                 :current_bid, :buy_now, keyword_init: true) do

  def self.build(line, transaction_kind)
    status = if !line[:class]
               'undetected'
             elsif line[:class].include?('outbid')
               'outbid'
             elsif line[:class].include?('won')
               'won'
             else
               'highest bid'
             end

    value_data = {}

    new(
      {
        timestamp: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
        kind: transaction_kind,
        name: line.find('.name').text,
        timeleft: ChronicDuration.parse(line.find('.auction-state .time').text),
        status: status
      }.merge(auction_data(line))
    )
  end

  def self.auction_data(line)
    value_data = {}
    [:start_price, :current_bid, :buy_now].each_with_index do |item, i|
      value = line.all('.auctionValue')[i].find('.value').text.gsub(',', '')
      value_data[item] = value.to_i
    end
    value_data
  end
end
