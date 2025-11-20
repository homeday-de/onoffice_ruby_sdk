# frozen_string_literal: true

class OnofficeClient
  def initialize(sdk: OnOfficeSDK.client)
    @sdk = sdk
  end

  def read_estates(limit: 10)
    params = { 'data' => %w[Id kaufpreis], 'listlimit' => limit }
    handle = @sdk.call_generic(OnOfficeSDK::SDK::ACTION_ID_READ, 'estate', params)
    @sdk.send_requests(token, secret)
    @sdk.get_response_array(handle)
  end

  private

  def token
    OnOfficeSDK.configuration.token || ENV.fetch('ONOFFICE_TOKEN', nil)
  end

  def secret
    OnOfficeSDK.configuration.secret || ENV.fetch('ONOFFICE_SECRET', nil)
  end
end
