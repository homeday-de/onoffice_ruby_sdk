# frozen_string_literal: true

require 'spec_helper'

class FakeHttpFetchSDKSpec
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
            'resourcetype' => 'estate',
            'cacheable' => false,
            'data' => [{ 'Id' => 1 }]
          }
        ]
      }
    }.to_json
  end
end

RSpec.describe OnOfficeSDK::SDK do
  let(:token) { 'test_token' }
  let(:secret) { 'test_secret' }

  it 'queues a call and retrieves a response via fake HTTP' do
    # Use Internal::ApiCall directly to inject fake fetch
    api_call = OnOfficeSDK::Internal::ApiCall.new
    api_call.set_server('https://api.onoffice.de/api/')
    api_call.set_api_version('stable')

    handle = api_call.call_by_raw_data(
      OnOfficeSDK::SDK::ACTION_ID_READ,
      '',
      '',
      'estate',
      { 'data' => ['Id'], 'listlimit' => 1 }
    )

    api_call.send_requests(token, secret, FakeHttpFetchSDKSpec.new)

    response = api_call.get_response(handle)
    expect(response).to be_a(Hash)
    expect(response['data']).to be_an(Array)
    expect(response['data'].first['Id']).to eq(1)
  end
end
