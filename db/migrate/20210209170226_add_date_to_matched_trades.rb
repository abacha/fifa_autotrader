class AddDateToMatchedTrades < ActiveRecord::Migration[6.0]
  def change
    add_column :matched_trades, :date, :date, null: false
  end
end
