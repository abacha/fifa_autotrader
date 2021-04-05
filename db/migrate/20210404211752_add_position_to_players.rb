class AddPositionToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :player_trades, :position, :string
    add_column :player_snipes, :position, :string
  end
end
