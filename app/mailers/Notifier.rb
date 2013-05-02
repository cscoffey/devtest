class Notifier < ActionMailer::Base
  default from: "noreply@easygrouper.com"

  def debug_email(anyText, sendTo, domain)
    @text = anyText
    @domain = domain
    @recipients = sendTo
    mail(:to => @recipients, :reply_to => "noreply@easygrouper.com", :subject => "Message from EasyGrouper")
  end
end
