class CreateMatchedTrades < ActiveRecord::Migration[6.0]
  def change
    create_table :matched_trades do |t|
      t.string :buy_trade_id
      t.string :sell_trade_id
      t.integer :profit
      t.integer :duration
      t.integer :timestamp
    end
  end
end
