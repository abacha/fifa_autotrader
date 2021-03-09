# frozen_string_literal: true

class Command
  LIST = %w[PAUSE RESTART]

  def self.check_all
    LIST.each { |cmd| check(cmd) }
  end

  def self.queue(cmd)
    return false unless LIST.include?(cmd)
    File.write(cmd, '')
    RobotLogger.msg("Queueing command: #{cmd}")
  end

  def self.queued?(cmd)
    File.exists?(cmd)
  end

  def self.check(cmd)
    return false unless LIST.include?(cmd)

    if queued?(cmd)
      FileUtils.rm_f(cmd)
      RobotLogger.msg("Executing command: #{cmd}")
      commands[cmd].call
    end
  end

  private

  def self.commands
    {
      'PAUSE' => -> { sleep 180 },
      'RESTART' => -> { exit 1 }
    }
  end
end
