class AddRarityToPlayers < ActiveRecord::Migration[6.0]
  def change

    add_column :players, :rarity, :string
  end
end
