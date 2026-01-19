# frozen_string_literal: true

# Class for Applcation Mailer
class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('SMTP_USER_NAME', nil)
  layout 'mailer'
end
