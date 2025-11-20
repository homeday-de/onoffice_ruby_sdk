# frozen_string_literal: true

require 'spec_helper'

class FakeHttpFetchError
  def http_options=(opts)
    @opts = opts
  end

  def send
    {
      'response' => {
        'results' => [
          {
            'status' => { 'errorcode' => 123, 'message' => 'Oops' },
            'actionid' => OnOfficeSDK::SDK::ACTION_ID_READ,
            'resourcetype' => 'estate'
          }
        ]
      }
    }.to_json
  end
end

RSpec.describe OnOfficeSDK::Internal::ApiCall do
  let(:token) { 'tok' }
  let(:secret) { 'sec' }

  it 'captures errors for failed actions and returns nil response' do
    api = described_class.new
    api.set_server('https://api.onoffice.de/api/')
    api.set_api_version('stable')

    handle = api.call_by_raw_data(OnOfficeSDK::SDK::ACTION_ID_READ, '', '', 'estate', { 'data' => ['Id'] })
    api.send_requests(token, secret, FakeHttpFetchError.new)

    expect(api.get_response(handle)).to be_nil
    expect(api.errors.keys).to include(handle)
    expect(api.errors[handle].dig('status', 'errorcode')).to eq(123)
  end
end
