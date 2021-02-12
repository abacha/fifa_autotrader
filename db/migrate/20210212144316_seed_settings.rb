class SeedSettings < ActiveRecord::Migration[6.0]
  def up
    YAML.load(File.read('config/settings.default.yml')).each do |key, value|
      Setting.create!(key: key, value: value)
    end
  end

  def down
    Setting.delete_all
  end
end
