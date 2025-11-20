# frozen_string_literal: true

module OnOfficeSDK
  class Configuration
    attr_accessor :api_server, :api_version, :open_timeout, :read_timeout,
                  :token, :secret, :use_rails_cache, :rails_cache_ttl

    def initialize
      @api_server = 'https://api.onoffice.de/api/'
      @api_version = 'stable'
      @open_timeout = 5
      @read_timeout = 30
      @token = nil
      @secret = nil
      @use_rails_cache = false
      @rails_cache_ttl = 300 # seconds
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      refresh_default_client!
    end

    def client
      @client ||= build_client_from_config
    end

    def refresh_default_client!
      @client = build_client_from_config
    end

    private

    def build_client_from_config
      sdk = OnOfficeSDK::SDK.new
      cfg = configuration
      sdk.set_api_server(cfg.api_server)
      sdk.set_api_version(cfg.api_version)
      sdk.set_http_options(open_timeout: cfg.open_timeout, read_timeout: cfg.read_timeout)
      if cfg.use_rails_cache && defined?(Rails)
        begin
          require_relative 'cache/rails_cache'
          sdk.add_cache(OnOfficeSDK::Cache::RailsCache.new(ttl: cfg.rails_cache_ttl))
        rescue LoadError
          # ignore if Rails cache adapter not available
        end
      end
      sdk
    end
  end
end
