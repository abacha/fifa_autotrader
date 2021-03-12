# frozen_string_literal: true

class Command
  LIST = %w[PAUSE RESTART SLEEP].freeze

  def self.check_all
    LIST.each { |cmd| check(cmd) }
  end

  def self.queue(cmd)
    return false unless LIST.include?(cmd)

    File.write(cmd, '')
    RobotLogger.msg("Queueing command: #{cmd}")
  end

  def self.queued?(cmd)
    File.exist?(cmd)
  end

  def self.check(cmd)
    return false unless LIST.include?(cmd)

    return unless queued?(cmd)

    FileUtils.rm_f(cmd)
    RobotLogger.msg("Executing command: #{cmd}")
    commands[cmd].call
  end

  def self.commands
    {
      'PAUSE' => -> { binding.pry },
      'SLEEP' => -> { sleep 180 },
      'RESTART' => -> { exit 1 }
    }
  end
end
