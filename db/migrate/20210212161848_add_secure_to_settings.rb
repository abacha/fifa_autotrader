class AddSecureToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :secure, :integer, null: false, default: 0
  end
end
