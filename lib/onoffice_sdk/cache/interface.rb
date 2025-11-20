# frozen_string_literal: true

module OnOfficeSDK
  module Cache
    # Informal interface for cache backends.
    # Implementers should provide the following methods:
    # - initialize(options = {})
    # - get_http_response_by_parameter_array(parameters) -> String or nil
    # - write(parameters, value) -> true/false
    # - cleanup
    # - clear_all
    module Interface
      def get_http_response_by_parameter_array(_parameters); end
      def write(_parameters, _value); end
      def cleanup; end
      def clear_all; end
    end
  end
end
