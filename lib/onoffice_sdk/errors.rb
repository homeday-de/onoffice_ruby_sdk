# frozen_string_literal: true

module OnOfficeSDK
  class SDKError < StandardError; end

  class ApiCallFaultyResponseError < SDKError; end
  class ApiCallNoActionParametersError < SDKError; end

  class HttpFetchNoResultError < SDKError
    attr_accessor :errno
  end
end
