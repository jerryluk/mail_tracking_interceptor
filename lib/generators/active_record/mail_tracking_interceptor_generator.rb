require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class MailTrackingInterceptorGenerator < ActiveRecord::Generators::Base

      source_root File.expand_path('../templates', __FILE__)

      def copy_migration
        migration_template "migrate_#{name}.rb", "db/migrate/create_#{name.pluralize}"
      end

      def generate_model
        invoke "active_record:model", [name], :migration => false
      end

      def inject_edmodo_content
        inject_into_class "app/models/#{name}.rb", name.classify, send("#{name}_content")
      end

      def email_stat_content
<<EOF
  STATUS = { ok: 'ok', bounce: 'bounce' }

  has_many :email_deliveries, dependent: :destroy

  validates_presence_of :email, on: :create
  before_create :generate_tag
  before_create :set_default_status

  def email=(e)
    write_attribute(:email, e.downcase) if e.present?
  end

private
  def generate_tag
    self.tag ||= SecureRandom.urlsafe_base64(16).gsub('-', '_')
  end

  def set_default_status
    self.status ||= STATUS[:ok]
  end
EOF
      end

      def email_delivery_content
<<EOF
  belongs_to :email_stat
  before_create :generate_tracking_code

private
  def generate_tracking_code
    self.tracking_code = SecureRandom.urlsafe_base64(16).gsub('-', '_')
  end
EOF
      end
    end
  end
end
