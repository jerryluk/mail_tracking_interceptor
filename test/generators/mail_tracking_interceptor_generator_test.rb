require "test_helper"

require "generators/active_record/mail_tracking_interceptor_generator"

class ActiveRecordGeneratorTest < Rails::Generators::TestCase
  tests ActiveRecord::Generators::MailTrackingInterceptorGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  test "all files are properly created" do
    run_generator %w(email_stat)
    assert_file "app/models/email_stat.rb"
    assert_migration "db/migrate/create_email_stats.rb", /def change/

    run_generator %w(email_delivery)
    assert_file "app/models/email_delivery.rb"
    assert_migration "db/migrate/create_email_deliveries.rb", /def change/
  end
end
