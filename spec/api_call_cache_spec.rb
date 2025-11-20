# frozen_string_literal: true

require 'spec_helper'

class FakeCache
  include OnOfficeSDK::Cache::Interface

  def initialize(_opts = {})
    @store = {}
  end

  def key_for(parameters)
    # Deterministic key using a stable serialization + md5
    require 'digest/md5'
    Digest::MD5.hexdigest(Marshal.dump(parameters))
  end

  def get_http_response_by_parameter_array(parameters)
    @store[key_for(parameters)]
  end

  def write(parameters, value)
    @store[key_for(parameters)] = value
    true
  end

  def cleanup; end

  def clear_all
    @store.clear
  end
end

class FakeHttpFetchCacheable
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
            'cacheable' => true,
            'data' => [{ 'Id' => 42 }]
          }
        ]
      }
    }.to_json
  end
end

class FakeHttpFetchRaise
  def http_options=(opts)
    @opts = opts
  end

  def send
    raise 'HTTP should not be called when cache hit'
  end
end

RSpec.describe OnOfficeSDK::Internal::ApiCall do
  let(:token) { 'tok' }
  let(:secret) { 'sec' }
  let(:params) { { 'data' => ['Id'], 'listlimit' => 1 } }

  it 'writes to cache on cacheable response and reads from cache on next call' do
    cache = FakeCache.new
    api = described_class.new
    api.set_server('https://api.onoffice.de/api/')
    api.set_api_version('stable')
    api.add_cache(cache)

    # First call: goes to HTTP and should write cache
    handle1 = api.call_by_raw_data(OnOfficeSDK::SDK::ACTION_ID_READ, '', '', 'estate', params)
    api.send_requests(token, secret, FakeHttpFetchCacheable.new)
    resp1 = api.get_response(handle1)
    expect(resp1.dig('data', 0, 'Id')).to eq(42)

    # Second call: identical params -> should use cache, not HTTP
    handle2 = api.call_by_raw_data(OnOfficeSDK::SDK::ACTION_ID_READ, '', '', 'estate', params)
    api.send_requests(token, secret, FakeHttpFetchRaise.new)
    resp2 = api.get_response(handle2)
    expect(resp2.dig('data', 0, 'Id')).to eq(42)
  end
end
