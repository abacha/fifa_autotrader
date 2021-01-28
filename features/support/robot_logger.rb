# frozen_string_literal: true

require 'logger'
require 'singleton'

class RobotLogger
  include Singleton

  LOG_FILE = 'tmp/logs/robot.log'

  def self.log(severity, msg)
    instance.log(severity, msg)
  end

  def logger
    @logger ||= Logger.new(LOG_FILE, 'daily')
  end

  def log(severity, msg)
    puts "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{msg}"
    logger.send(severity, msg)
  end

  def self.tail(n = 100)
    `tail -n#{n} #{LOG_FILE}`
  end
end
