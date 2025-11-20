# frozen_string_literal: true

require 'spec_helper'

class FakeHttpFetchTwo
  def http_options=(opts)
    @opts = opts
  end

  def send
    {
      'response' => {
        'results' => [
          { 'status' => { 'errorcode' => 123 }, 'actionid' => OnOfficeSDK::SDK::ACTION_ID_READ,
            'resourcetype' => 'estate' },
          { 'status' => { 'errorcode' => 0 }, 'actionid' => OnOfficeSDK::SDK::ACTION_ID_READ,
            'resourcetype' => 'estate', 'data' => [{ 'Id' => 9 }], 'cacheable' => false }
        ]
      }
    }.to_json
  end
end

RSpec.describe OnOfficeSDK::Internal::ApiCall do
  it 'maps multi-action responses and errors to the correct handles' do
    api = described_class.new
    api.set_server('https://api.onoffice.de/api/')
    api.set_api_version('stable')

    h_err = api.call_by_raw_data(OnOfficeSDK::SDK::ACTION_ID_READ, '', '', 'estate', { 'data' => [] })
    h_ok  = api.call_by_raw_data(OnOfficeSDK::SDK::ACTION_ID_READ, '', '', 'estate', { 'data' => ['Id'] })

    api.send_requests('tok', 'sec', FakeHttpFetchTwo.new)

    # Error handle has no response, but appears in errors
    expect(api.get_response(h_err)).to be_nil
    expect(api.errors.keys).to include(h_err)

    # Success handle returns data
    resp_ok = api.get_response(h_ok)
    expect(resp_ok.dig('data', 0, 'Id')).to eq(9)
  end
end
