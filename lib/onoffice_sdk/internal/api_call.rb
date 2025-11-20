# frozen_string_literal: true

require 'json'

module OnOfficeSDK
  module Internal
    class ApiCall
      def initialize
        @request_queue = {}
        @responses = {}
        @errors = {}
        @api_version = 'stable'
        @caches = []
        @server = nil
        @http_options = {}
      end

      def call_by_raw_data(action_id, resource_id, identifier, resource_type, parameters = {})
        p_api_action = ApiAction.new(action_id, resource_type, parameters, resource_id, identifier)
        p_request = Request.new(p_api_action)
        request_id = p_request.request_id
        @request_queue[request_id] = p_request
        request_id
      end

      def send_requests(token, secret, http_fetch = nil)
        collect_or_gather_requests(token, secret, http_fetch)
      end

      def set_http_options(opts)
        @http_options = opts || {}
      end

      def get_response(handle)
        if @responses.key?(handle)
          p_response = @responses[handle]
          raise ApiCallFaultyResponseError, "Handle: #{handle}" unless p_response.valid?

          @responses.delete(handle)
          return p_response.response_data
        end
        nil
      end

      def set_api_version(v)
        @api_version = v
      end

      def set_server(server)
        @server = server
      end

      attr_reader :errors

      def add_cache(cache)
        @caches << cache
      end

      def remove_cache_instances
        @caches = []
      end

      private

      def collect_or_gather_requests(token, secret, http_fetch)
        action_parameters = []
        action_parameters_order = []

        @request_queue.each_value do |p_request|
          used_parameters = p_request.api_action.action_parameters
          cached_response = get_from_cache(used_parameters)
          if cached_response.nil?
            parameters_this_action = p_request.create_request(token, secret)
            action_parameters << parameters_this_action
            action_parameters_order << p_request
          else
            @responses[p_request.request_id] = Response.new(p_request, cached_response)
          end
        end

        send_http_requests(token, action_parameters, action_parameters_order, http_fetch)
        @request_queue = {}
      end

      def send_http_requests(token, action_parameters, action_parameters_order, http_fetch)
        return if action_parameters.empty?

        response_http = get_from_http(token, action_parameters, http_fetch)
        result = JSON.parse(response_http)
        raise HttpFetchNoResultError unless result.dig('response', 'results')

        ids_for_cache = []

        result['response']['results'].each_with_index do |result_http, request_number|
          p_request = action_parameters_order[request_number]
          request_id = p_request.request_id
          if result_http.dig('status', 'errorcode').to_i.zero?
            @responses[request_id] = Response.new(p_request, result_http)
            ids_for_cache << request_id
          else
            @errors[request_id] = result_http
          end
        end

        write_cache_for_responses(ids_for_cache)
      end

      def get_from_http(token, action_parameters, http_fetch)
        request = {
          'token' => token,
          'request' => { 'actions' => action_parameters }
        }
        if http_fetch.nil?
          http_fetch = HttpFetch.new(api_url, JSON.generate(request))
          http_fetch.http_options = @http_options
        end
        if defined?(ActiveSupport::Notifications)
          ActiveSupport::Notifications.instrument('onoffice_sdk.request',
                                                  url: api_url,
                                                  actions_count: action_parameters.size) do
            http_fetch.send
          end
        else
          http_fetch.send
        end
      end

      def write_cache_for_responses(response_ids)
        return if @caches.empty?

        response_objects = @responses.slice(*response_ids).values
        response_objects.each do |p_response|
          next unless p_response.cacheable?

          response_data = p_response.response_data
          request_parameters = p_response.request.api_action.action_parameters
          write_cache(JSON.generate(response_data), request_parameters)
        end
      end

      def write_cache(result, action_parameters)
        @caches.each { |cache| cache.write(action_parameters, result) }
      end

      def get_from_cache(parameters)
        @caches.each do |cache|
          result_cache = cache.get_http_response_by_parameter_array(parameters)
          next if result_cache.nil?

          begin
            return JSON.parse(result_cache)
          rescue JSON::ParserError
            # ignore invalid cache content
          end
        end
        nil
      end

      def api_url
        raise SDKError, 'Server not set' unless @server

        base = @server.end_with?('/') ? @server : "#{@server}/"
        "#{base}#{URI.encode_www_form_component(@api_version)}/api.php"
      end
    end
  end
end
