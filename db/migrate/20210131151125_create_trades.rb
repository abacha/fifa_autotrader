class CreateTrades < ActiveRecord::Migration[6.0]
  def change
    create_table :trades do |t|
      t.datetime :timestamp
      t.string :kind
      t.string :player_name
      t.integer :start_price
      t.integer :sold_for
      t.integer :buy_now
    end
  end
end
