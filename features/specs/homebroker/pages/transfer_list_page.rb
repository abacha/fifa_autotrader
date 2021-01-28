# frozen_string_literal: true

class TransferListPage < BasePage
  def clear
    click_on 'Transfers'
    clear_finished('S', '.ut-tile-transfer-list')
    relist_players
  end

  def update_stock
    stock = auctions.inject(Hash.new(0)) { |h, e| h[e.name] += 1; h }
    RobotLogger.log(:info, { stock: stock })
    Stock.save(stock)
  end

  def relist_players
    if has_css?('.has-auction-data.expired')
      RobotLogger.log(:info, { method: 'relist_players' })
      click_on 'Re-list All'
      click_on 'Yes'
    end
  end

  def auctions
    click_on 'Transfers'
    find('.ut-tile-transfer-list').click

    auctions_list = all('.has-auction-data')
    RobotLogger.log(:info, { kind: 'active selling', amount: auctions_list.count })
    auctions_list.map { |line| Auction.build(line) }
  end
end
