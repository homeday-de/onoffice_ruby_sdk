# frozen_string_literal: true

require 'rails/railtie'

module OnOfficeSDK
  class Railtie < ::Rails::Railtie
    config.onoffice_sdk = ActiveSupport::OrderedOptions.new

    initializer 'onoffice_sdk.configure' do |app|
      cfg = app.config.onoffice_sdk

      OnOfficeSDK.configure do |c|
        c.api_server = cfg.api_server || ENV['ONOFFICE_API_BASE'] || c.api_server
        c.api_version = cfg.api_version || ENV['ONOFFICE_API_VERSION'] || c.api_version
        c.open_timeout = cfg.open_timeout || c.open_timeout
        c.read_timeout = cfg.read_timeout || c.read_timeout

        c.token = cfg.token || begin
          Rails.application.credentials.dig(:onoffice,
                                            :token)
        rescue StandardError
          nil
        end || ENV.fetch('ONOFFICE_TOKEN', nil)
        c.secret = cfg.secret || begin
          Rails.application.credentials.dig(:onoffice,
                                            :secret)
        rescue StandardError
          nil
        end || ENV.fetch('ONOFFICE_SECRET', nil)

        c.use_rails_cache = cfg.fetch(:use_rails_cache, c.use_rails_cache)
        c.rails_cache_ttl = cfg.rails_cache_ttl || c.rails_cache_ttl
      end
    end
  end
end
