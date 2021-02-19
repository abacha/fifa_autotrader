# frozen_string_literal: true

class Stock
  STOCK_FILE = "#{ENV['TMP_FOLDER']}/stock.yml"

  def self.save(auctions)
    File.open(STOCK_FILE, 'w') { |file| file.write(auctions.to_yaml) }
  end

  def self.all
    YAML.load(File.read(STOCK_FILE))
  end

  def self.count
    all.inject(Hash.new(0)) { |h, e| h[e.player_name] += 1; h }
  end

  def self.by_player(player_name)
    data = count.detect { |name, _| name == player_name }
    data ? data[1].to_i : 0
  end
end
