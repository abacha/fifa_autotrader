class AddGroupToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :group, :string
  end
end
