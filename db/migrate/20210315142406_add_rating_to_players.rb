class AddRatingToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :rating, :integer
    add_column :player_snipes, :rating, :integer
  end
end
