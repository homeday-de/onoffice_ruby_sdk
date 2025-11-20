# frozen_string_literal: true

require 'spec_helper'

class BadJsonCache
  include OnOfficeSDK::Cache::Interface

  def get_http_response_by_parameter_array(_parameters)
    'not-json'
  end

  def write(_parameters, _value)
    true
  end

  def cleanup; end
  def clear_all; end
end

class FakeHttpFetchOnce
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
            'data' => []
          }
        ]
      }
    }.to_json
  end
end

RSpec.describe OnOfficeSDK::Internal::ApiCall do
  it 'ignores bad JSON from cache and falls back to HTTP' do
    api = described_class.new
    api.set_server('https://api.onoffice.de/api/')
    api.set_api_version('stable')
    api.add_cache(BadJsonCache.new)

    handle = api.call_by_raw_data(OnOfficeSDK::SDK::ACTION_ID_READ, '', '', 'estate', { 'data' => ['Id'] })
    api.send_requests('tok', 'sec', FakeHttpFetchOnce.new)
    resp = api.get_response(handle)
    expect(resp).to be_a(Hash)
  end
end
