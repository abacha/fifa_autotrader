# frozen_string_literal: true

class TransferListPage < BasePage
  class InvalidListError < StandardError; end

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
        raise InvalidListError, 'Invalid list' if all('.has-auction-data.won').count != auctions.size
        click_on 'Clear Sold'
      end
    end

    TradeMatcher.match_trades
    RobotLogger.msg("Cleared #{trades.count} sold players")
  end

  private

  def page_menu_link
    '.ut-tile-transfer-list'
  end
end
