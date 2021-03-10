# frozen_string_literal: true

module ErrorCapturer
  include Capybara::DSL
  ERRORS_FOLDER = "#{ENV['TMP_FOLDER']}/errors"

  def record_error(message)
    id = rand(1000)
    datetime = Time.now.strftime('%Y%m%d_%H%M%S_%L')
    basename = "#{ERRORS_FOLDER}/#{datetime}_#{id}"
    File.write("#{basename}.log", message)
    save_screenshot("#{basename}.png")
    save_page("#{basename}.html")
  end

  def self.last_error
    image = Dir['public/errors/*.png'].max

    return OpenStruct.new unless image

    hash = image.match(%r{/(\d{3}_.*?)\.})[1]
    img_path = image.gsub('public', '')
    timestamp = image.match(/\d{8}_\d{6}/)[0]
    error_msg = File.read("#{ERRORS_FOLDER}/#{hash}.log")

    OpenStruct.new(
      img_path: img_path,
      error_msg: error_msg,
      timestamp: DateTime.parse(timestamp).strftime('%Y-%m-%d %H:%M:%S')
    )
  end
end
