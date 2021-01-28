# frozen_string_literal: true

class Stock
  STOCK_FILE = 'stock.yml'

  def self.save(auction_data)
    File.open(STOCK_FILE, 'w') { |file| file.write(auction_data.to_yaml) }

    RobotLogger.log(:info, { msg: 'Stock updated' })
  end

  def self.all
    YAML.load(File.read(STOCK_FILE))
  end

  def self.by_player(player_name)
    data = all.detect { |name, _| name == player_name }
    data ? data[1].to_i : 0
  end
end
