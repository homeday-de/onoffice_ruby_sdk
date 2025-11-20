# frozen_string_literal: true

require 'spec_helper'

class SpyCache
  include OnOfficeSDK::Cache::Interface
  attr_reader :writes

  def initialize(*)
    @writes = 0
  end

  def get_http_response_by_parameter_array(_)
    nil
  end

  def write(_p, _v)
    @writes += 1
    true
  end

  def cleanup; end
  def clear_all; end
end

class FakeHttpFetchNonCacheable
  def http_options=(opts)
    @opts = opts
  end

  def send
    {
      'response' => {
        'results' => [
          { 'status' => { 'errorcode' => 0 }, 'actionid' => OnOfficeSDK::SDK::ACTION_ID_READ,
            'resourcetype' => 'estate', 'cacheable' => false, 'data' => [] }
        ]
      }
    }.to_json
  end
end

RSpec.describe OnOfficeSDK::Internal::ApiCall do
  it 'does not write cache when response is not cacheable even if caches exist' do
    api = described_class.new
    api.set_server('https://api.onoffice.de/api/')
    api.set_api_version('stable')
    spy = SpyCache.new
    api.add_cache(spy)
    h = api.call_by_raw_data(OnOfficeSDK::SDK::ACTION_ID_READ, '', '', 'estate', { 'data' => [] })
    api.send_requests('tok', 'sec', FakeHttpFetchNonCacheable.new)
    expect(api.get_response(h)).to be_a(Hash)
    expect(spy.writes).to eq(0)
  end
end
