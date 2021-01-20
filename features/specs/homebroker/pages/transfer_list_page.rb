# frozen_string_literal: true

class TransferListPage < BasePage
  def clear
    click_on 'Transfers'
    clear_finished('S', '.ut-tile-transfer-list', 'Clear Sold')
    relist_players
  end

  def update_stock
    player_list = all('.has-auction-data')
  end

  def relist_players
    if has_css?('.has-auction-data.expired')
      ElkLogger.log(:info, { method: 'relist_players' })
      click_on 'Re-list All'
      click_on 'Yes'
    end
  end

  def list
    click_on 'Transfers'
    find('.ut-tile-transfer-list').click

    player_list = all('.has-auction-data')
    ElkLogger.log(:info, { kind: 'active selling', amount: player_list.count })
    # ElkLogger.log(:info, { kind: 'outbid', amount: all('.has-auction-data.outbid').count })
    # ElkLogger.log(:info, { kind: 'highest bid', amount: all('.has-auction-data.highest-bid').count })
  end
end
