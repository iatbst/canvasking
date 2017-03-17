class ApplicationMailer < ActionMailer::Base
  default from: ENV['order_email']
  layout 'mailer'
end
