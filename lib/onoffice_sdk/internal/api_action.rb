# frozen_string_literal: true

module OnOfficeSDK
  module Internal
    class ApiAction
      def initialize(action_id, resource_type, parameters, resource_id = '', identifier = '', timestamp = nil)
        sorted_params = parameters.is_a?(Hash) ? parameters.sort.to_h : parameters
        @action_parameters = {
          'actionid' => action_id,
          'identifier' => identifier,
          'parameters' => sorted_params,
          'resourceid' => resource_id,
          'resourcetype' => resource_type,
          'timestamp' => timestamp
        }
      end

      attr_reader :action_parameters

      def identifier
        # Deterministic identifier for caching
        require 'digest/md5'
        Digest::MD5.hexdigest(Marshal.dump(@action_parameters))
      end
    end
  end
end
