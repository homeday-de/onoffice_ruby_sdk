# frozen_string_literal: true

require 'net/http'
require 'uri'

module OnOfficeSDK
  module Internal
    class HttpFetch
      def initialize(url, post_data)
        @url = url
        @post_data = post_data
        @http_options = {}
      end

      def http_options=(opts)
        @http_options = opts || {}
      end

      def send
        uri = URI.parse(@url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        # Timeouts / options
        http.open_timeout = @http_options[:open_timeout] if @http_options[:open_timeout]
        http.read_timeout = @http_options[:read_timeout] if @http_options[:read_timeout]

        req = Net::HTTP::Post.new(uri.request_uri)
        req['Content-Type'] = 'application/json'
        req['Accept-Encoding'] = 'gzip,deflate,br'
        req.body = @post_data

        res = http.request(req)
        body = res&.body
        unless res.is_a?(Net::HTTPSuccess) && body
          err = HttpFetchNoResultError.new(res&.code.to_s)
          err.errno = nil
          raise err
        end
        body
      end
    end
  end
end
