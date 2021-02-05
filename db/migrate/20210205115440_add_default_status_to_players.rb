class AddDefaultStatusToPlayers < ActiveRecord::Migration[6.0]
  def change
    change_column :players, :status, :integer, default: 0
  end
end
