class CreateSettings < ActiveRecord::Migration[6.0]
  def up
    create_table :settings do |t|
      t.string :key
      t.text :value
    end

    YAML.load(File.read('config/settings.default.yml')).each do |key, value|
      Setting.create!(key: key, value: value)
    end
  end

  def down
    drop_table :settings
  end
end
