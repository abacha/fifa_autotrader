class AddPlayerNameToMatchedTrades < ActiveRecord::Migration[6.0]
  def change
    add_column :matched_trades, :player_name, :string
  end
end
