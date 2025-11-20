# frozen_string_literal: true

require 'spec_helper'

class FakeHttpFetchInvalid
  def http_options=(opts)
    @opts = opts
  end

  def send
    {
      'response' => {
        'results' => [
          {
            'status' => { 'errorcode' => 0 },
            'actionid' => OnOfficeSDK::SDK::ACTION_ID_READ,
            'resourcetype' => 'estate'
            # Missing 'data' to make Response invalid
          }
        ]
      }
    }.to_json
  end
end

RSpec.describe OnOfficeSDK::Internal::ApiCall do
  it 'raises ApiCallFaultyResponseError when response is invalid' do
    api = described_class.new
    api.set_server('https://api.onoffice.de/api/')
    api.set_api_version('stable')
    handle = api.call_by_raw_data(OnOfficeSDK::SDK::ACTION_ID_READ, '', '', 'estate', { 'data' => ['Id'] })

    api.send_requests('tok', 'sec', FakeHttpFetchInvalid.new)

    expect { api.get_response(handle) }.to raise_error(OnOfficeSDK::ApiCallFaultyResponseError)
  end
end
