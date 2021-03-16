class ChangePlayersName < ActiveRecord::Migration[6.0]
  def change
    rename_table :players, :player_trades
  end
end
