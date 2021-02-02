class AddMatchedFlagToTrades < ActiveRecord::Migration[6.0]
  def change
    add_column :trades, :matched, :integer, default: 0
  end
end
