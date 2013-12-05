require "mail_tracking_interceptor/version"

module MailTrackingInterceptor
  MAIL_TRACKING_SIGNATURE = "__mail_tracking_code__"
  MAIL_TAG_SIGNATURE = "__mail_tag__"

  # This class intercepts the Email and do the following:
  # 1. It finds or creates EmailStat based on the FIRST recipient, and add tag to the from, reply-to,
  #    and return-path.
  # 2. If the EmailStat status is not OK, it will set perform_deliveries to false.
  # 3. It creates EmailDelivery and adds tracking code to the body (or HTML body)
  #
  class Interceptor
    TRACKING_CODE_REGEX = Regexp.new(MAIL_TRACKING_SIGNATURE)
    TAG_REGEX = Regexp.new(MAIL_TAG_SIGNATURE)

    class << self
      def delivering_email(message)
        email_stat = EmailStat.where(:email => message.to.first).first_or_create!
        message.perform_deliveries = false unless email_stat.status == EmailStat::STATUS[:ok]
        message.from = field_with_tag(message[:from], email_stat.tag)
        message.reply_to = field_with_tag(message[:reply_to], email_stat.tag)
        message.return_path = field_with_tag(message[:return_path], email_stat.tag)

        if message.perform_deliveries
          email_delivery = EmailDelivery.create!(:email_stat => email_stat, :subject => message.subject)
          if message.parts.present?
            message.text_part.body = body_with_tracking_code(message.text_part.body, email_delivery.tracking_code) if message.text_part
            message.html_part.body = body_with_tracking_code(message.html_part.body, email_delivery.tracking_code) if message.html_part
          elsif message.body.decoded.present?
            message.body = body_with_tracking_code(message.body, email_delivery.tracking_code)
          end
          ActionMailer::Base.logger.info("Track mail #{email_delivery.tracking_code} to #{message.to.try :join, ' ,'} with subject \"#{message.subject}\" at #{Time.now}")
        end
      end

    private

      def field_with_tag(field, tag)
        field.decoded.gsub(TAG_REGEX, tag) if field.present?
      end

      def body_with_tracking_code(body, tracking_code)
        body.decoded.gsub(TRACKING_CODE_REGEX, tracking_code) if body.present?
      end
    end

  end


end
