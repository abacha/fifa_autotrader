class CreatePlayers < ActiveRecord::Migration[6.0]
  def change
    create_table :players do |t|
      t.string :name
      t.string :fullname
      t.integer :max_bid
      t.integer :sell_value
      t.integer :status
      t.string :futbin_id
      t.string :resource_id
    end
  end
end
