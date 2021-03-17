# frozen_string_literal: true

class TransferListPage < BasePage
  PAGE_MENU_LINK = '.ut-tile-transfer-list'

  def update_stock
    enter_page

    stock = build_auctions
    RobotLogger.log(:info, { action: 'auctions', amount: stock.count })
    Stock.save(stock)
    RobotLogger.msg("Stock updated: #{Stock.count}")
  end

  def relist_players
    enter_page

    if has_button?('Re-list All')
      RobotLogger.msg('Relisting expired auctions')
      click_on 'Re-list All'
      click_on 'Yes'
    end
  end

  def clear_sold
    enter_page

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
          "Player sold: #{trade.player_name} ($#{trade.sold_for})"
        )
        click_on 'Clear Sold'
      end
    end

    TradeMatcher.match_trades
    RobotLogger.msg("Cleared #{trades.count} sold players")
  end
end
