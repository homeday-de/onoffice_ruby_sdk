# frozen_string_literal: true

require 'json'
require 'base64'
require 'openssl'

module OnOfficeSDK
  module Internal
    class Request
      @request_id_static = 0
      class << self
        attr_accessor :request_id_static
      end

      def initialize(api_action)
        @api_action = api_action
        @request_id = (self.class.request_id_static ||= 0)
        self.class.request_id_static += 1
      end

      def create_request(token, secret)
        action_parameters = @api_action.action_parameters.dup
        action_parameters['timestamp'] ||= Time.now.to_i
        action_parameters['hmac_version'] = 2

        action_id = action_parameters['actionid']
        type = action_parameters['resourcetype']
        hmac = create_hmac2(token, secret, action_parameters['timestamp'], type, action_id)
        action_parameters['hmac'] = hmac

        action_parameters
      end

      def create_hmac2(token, secret, timestamp, type, action_id)
        fields = {
          'timestamp' => timestamp,
          'token' => token,
          'resourcetype' => type,
          'actionid' => action_id
        }
        raw = fields.values.join
        digest = OpenSSL::HMAC.digest('sha256', secret.to_s, raw)
        Base64.strict_encode64(digest)
      end

      attr_reader :request_id, :api_action
    end
  end
end
