# frozen_string_literal: true

require 'spec_helper'

class FakeHttpFetchCacheableBare
  def http_options=(opts)
    @opts = opts
  end

  def send
    {
      'response' => {
        'results' => [
          { 'status' => { 'errorcode' => 0 }, 'actionid' => OnOfficeSDK::SDK::ACTION_ID_READ,
            'resourcetype' => 'estate', 'cacheable' => true, 'data' => [] }
        ]
      }
    }.to_json
  end
end

RSpec.describe OnOfficeSDK::Internal::ApiCall do
  it 'handles cacheable responses when no caches are registered' do
    api = described_class.new
    api.set_server('https://api.onoffice.de/api/')
    api.set_api_version('stable')
    h = api.call_by_raw_data(OnOfficeSDK::SDK::ACTION_ID_READ, '', '', 'estate', { 'data' => [] })
    api.send_requests('tok', 'sec', FakeHttpFetchCacheableBare.new)
    expect(api.get_response(h)).to be_a(Hash)
  end
end
