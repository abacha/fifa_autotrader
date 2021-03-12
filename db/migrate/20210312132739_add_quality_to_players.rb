class AddQualityToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :quality, :string
  end
end
