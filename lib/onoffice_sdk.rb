# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

require_relative 'onoffice_sdk/version'
require_relative 'onoffice_sdk/configuration'
require_relative 'onoffice_sdk/sdk'
require_relative 'onoffice_sdk/internal/api_call'
require_relative 'onoffice_sdk/internal/api_action'
require_relative 'onoffice_sdk/internal/request'
require_relative 'onoffice_sdk/internal/response'
require_relative 'onoffice_sdk/internal/http_fetch'
require_relative 'onoffice_sdk/cache/interface'
require_relative 'onoffice_sdk/errors'

# Auto-load Railtie if in Rails
begin
  require_relative 'onoffice_sdk/railtie' if defined?(Rails::Railtie)
rescue LoadError
  # ignore when Rails is not present
end
