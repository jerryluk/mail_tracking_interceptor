require "spec_helper"
require "mail"
require "mail_tracking_interceptor"

describe MailTrackingInterceptor::Interceptor do
  let(:message) {
    Mail.new do
      from "Test <tests+#{MailTrackingInterceptor::MAIL_TAG_SIGNATURE}@example.com>"
      to "test@example.com"
      reply_to "Test <tests+#{MailTrackingInterceptor::MAIL_TAG_SIGNATURE}@example.com>"
      return_path "tests+#{MailTrackingInterceptor::MAIL_TAG_SIGNATURE}@example.com"
    end
  }
  let(:email_stat) { EmailStat.create!(:email => "test@example.com") }

  it "creates EmailStat if no emails send to this address before" do
    expect {
      MailTrackingInterceptor::Interceptor .delivering_email(message)
    }.to change(EmailStat, :count).by(1)
    EmailStat.last.email.should == "test@example.com"
  end

  it "should not create EmailStat if email has sent before" do
    email_stat
    expect {
      MailTrackingInterceptor::Interceptor .delivering_email(message)
    }.to_not change(EmailStat, :count)
  end

  it "should send the email if the EmailStat status is 'ok'" do
    EmailStat.create!(:email => "test@example.com", :status => EmailStat::STATUS[:ok])
    MailTrackingInterceptor::Interceptor .delivering_email(message)
    message.perform_deliveries.should == true
  end

  it "should not send the email if the EmailStat status is not 'ok'" do
    EmailStat.create!(:email => "test@example.com", :status => EmailStat::STATUS[:bounce])
    MailTrackingInterceptor::Interceptor .delivering_email(message)
    message.perform_deliveries.should == false
  end

  it "adds tag to from field" do
    email_stat
    MailTrackingInterceptor::Interceptor .delivering_email(message)
    message[:from].to_s.should == "Test <tests+#{email_stat.tag}@example.com>"
  end

  it "adds tag to reply-to field" do
    email_stat
    MailTrackingInterceptor::Interceptor .delivering_email(message)
    message[:reply_to].to_s.should == "Test <tests+#{email_stat.tag}@example.com>"
  end

  it "adds tag to return-path" do
    email_stat
    MailTrackingInterceptor::Interceptor .delivering_email(message)
    message.return_path.to_s.should == "tests+#{email_stat.tag}@example.com"
  end

  it "creates email delivery record" do
    expect {
      MailTrackingInterceptor::Interceptor .delivering_email(message)
    }.to change(EmailDelivery, :count).by(1)
  end

  it "adds tracking codes to body" do
    message.body "Testing #{MailTrackingInterceptor::MAIL_TRACKING_SIGNATURE}"
    MailTrackingInterceptor::Interceptor .delivering_email(message)
    message.body.should include EmailDelivery.last.tracking_code
  end

  it "adds tracking codes to text and HTML body on multipart message" do
    message.text_part do |p|
      p.body = "Testing #{MailTrackingInterceptor::MAIL_TRACKING_SIGNATURE}"
    end
    message.html_part do |p|
      p.body = "Testing #{MailTrackingInterceptor::MAIL_TRACKING_SIGNATURE}"
    end
    MailTrackingInterceptor::Interceptor .delivering_email(message)
    message.text_part.body.should include EmailDelivery.last.tracking_code
    message.html_part.body.should include EmailDelivery.last.tracking_code
  end
end

