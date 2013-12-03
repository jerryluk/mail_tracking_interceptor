# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mail_tracking_interceptor/version'

Gem::Specification.new do |spec|
  spec.name          = "mail_tracking_interceptor"
  spec.version       = MailTrackingInterceptor::VERSION
  spec.authors       = ["Jerry Luk"]
  spec.email         = ["jerryluk@gmail.com"]
  spec.description   = %q{To track emails}
  spec.summary       = %q{To track emails}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 4.0.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "generator_spec"
  spec.add_development_dependency "factory_girl_rails"
end
