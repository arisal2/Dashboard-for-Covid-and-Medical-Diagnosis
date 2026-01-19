# frozen_string_literal: true

# Class for custom log
class CustomLog
  def self.debug(message = nil)
    @my_log ||= Logger.new(Rails.root.join('log/email.log').to_s)
    @my_log.debug(message) unless message.nil?
  end
end
