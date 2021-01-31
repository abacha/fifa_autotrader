# frozen_string_literal: true

class TransferListPage < BasePage
  def clear
    clear_sold
    relist_players
  end

  def update_stock
    stock = auctions.inject(Hash.new(0)) { |h, e| h[e.name] += 1; h }
    Stock.save(stock)
    RobotLogger.log(:info, { action: 'update_stock', stock: stock })
  end

  def relist_players
    if has_css?('.has-auction-data.expired')
      RobotLogger.log(:info, { action: 'relist_players' })
      click_on 'Re-list All'
      click_on 'Yes'
    end
  end

  def auctions
    click_on 'Transfers'
    find('.ut-tile-transfer-list').click

    auctions_list = all('.has-auction-data')
    RobotLogger.log(:info, { action: 'auctions', amount: auctions_list.count })
    auctions_list.map { |line| Auction.build(line) }
  end

  def clear_sold
    click_on 'Transfers'
    find('.ut-tile-transfer-list').click

    auctions = all('.has-auction-data.won').count
    RobotLogger.log(:info, { action: 'clear_sold', amount: auctions })

    0.upto(auctions - 1) do |i|
      line = all('.has-auction-data.won')[i]

      next unless line

      auction = Auction.build(line)
      auction.kind = 'S'
      player = Player.find_by(name: auction.name)

      next unless player

      RobotLogger.log(:info, auction.to_h)
      click_on 'Remove'
      Trade.create!(auction.values)
    end
  end
end
