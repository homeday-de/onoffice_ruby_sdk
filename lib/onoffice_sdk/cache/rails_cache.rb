# frozen_string_literal: true

require 'digest/md5'

module OnOfficeSDK
  module Cache
    class RailsCache
      include OnOfficeSDK::Cache::Interface

      def initialize(options = {})
        @namespace = options[:namespace] || 'onoffice'
        @ttl = options[:ttl] || 300
      end

      def get_http_response_by_parameter_array(parameters)
        return nil unless defined?(Rails)

        Rails.cache.read(key(parameters))
      end

      def write(parameters, value)
        return false unless defined?(Rails)

        Rails.cache.write(key(parameters), value, expires_in: @ttl)
      end

      def cleanup; end

      def clear_all
        return unless defined?(Rails)

        # Best-effort namespaced clear
        Rails.cache.delete_matched("#{@namespace}:*") if Rails.cache.respond_to?(:delete_matched)
      end

      private

      def key(parameters)
        digest = Digest::MD5.hexdigest(Marshal.dump(parameters))
        "#{@namespace}:#{digest}"
      end
    end
  end
end
