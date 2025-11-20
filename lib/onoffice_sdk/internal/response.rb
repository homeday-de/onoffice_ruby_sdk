# frozen_string_literal: true

module OnOfficeSDK
  module Internal
    class Response
      def initialize(request, response_data)
        @request = request
        @response_data = response_data
      end

      def valid?
        @response_data.is_a?(Hash) &&
          @response_data.key?('actionid') &&
          @response_data.key?('resourcetype') &&
          @response_data.key?('data')
      end

      def cacheable?
        valid? && @response_data['cacheable']
      end

      attr_reader :request, :response_data
    end
  end
end
