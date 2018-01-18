# frozen_string_literal: true

require 'rails/version'

if Rails::VERSION::MAJOR == 5
  require_relative 'boot'

  %w(
    action_controller
    action_mailer
    active_resource
    rails/test_unit
  ).each do |framework|
    begin
      require "#{framework}/railtie"
    rescue LoadError
    end
  end

  Bundler.require(*Rails.groups)
  require 'rails-letsencrypt-mongoid'

  module Dummy
    class Application < Rails::Application
      config.load_defaults 5.1
    end
  end

else
  require File.expand_path('../boot', __FILE__)

  # Pick the frameworks you want:
  # require 'active_record/railtie'
  require 'action_controller/railtie'
  require 'action_mailer/railtie'
  require 'action_view/railtie'
  require 'sprockets/railtie'

  Bundler.require(*Rails.groups)
  require 'rails-letsencrypt-mongoid'

  module Dummy
    class Application < Rails::Application
      config.active_record.raise_in_transactional_callbacks = true
    end
  end
end
