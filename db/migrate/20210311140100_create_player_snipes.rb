class CreatePlayerSnipes < ActiveRecord::Migration[6.0]
  def change
    create_table :player_snipes do |t|
      t.string :name
      t.string :fullname
      t.string :rarity
      t.string :quality
      t.integer :max_bid
      t.integer :bought, default: 0
    end
  end
end
