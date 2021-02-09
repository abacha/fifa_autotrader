# frozen_string_literal: true

class TransferListPage < BasePage
  PAGE_MENU_LINK = '.ut-tile-transfer-list'

  def update_stock
    stock = auctions.inject(Hash.new(0)) { |h, e| h[e.player_name] += 1; h }
    Stock.save(stock)
    RobotLogger.msg("Stock updated: #{stock}")
  end

  def relist_players
    click_on 'Transfers'
    find(PAGE_MENU_LINK).click

    if has_css?('.has-auction-data.expired')
      RobotLogger.msg('Relisting expired auctions')
      click_on 'Re-list All'
      click_on 'Yes'
    end
  end

  def auctions
    click_on 'Transfers'
    find(PAGE_MENU_LINK).click

    auctions_list = all('.has-auction-data')
    RobotLogger.log(:info, { action: 'auctions', amount: auctions_list.count })
    auctions_list.map { |line| Auction.build(line) }
  end

  def clear_sold
    click_on 'Transfers'
    find('.ut-tile-transfer-list').click

    auctions = all('.has-auction-data.won')

    return unless auctions.any?

    trades = auctions.map do |auction|
      auction = Auction.build(auction).to_trade('S')
      player = Player.find_by(name: auction[:player_name])
      next unless player
      Trade.new(auction)
    end.compact

    ActiveRecord::Base.transaction do
      trades.map do |trade|
        trade.save!
        RobotLogger.msg(
          "Player sold: #{trade.player_name} ($#{trade.sold_for})")
        click_on 'Clear Sold'
      end
    end

    TradeMatcher.match_trades
    RobotLogger.msg("Cleared #{trades.count} players")
  end
end
