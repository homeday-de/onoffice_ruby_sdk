# frozen_string_literal: true

require 'spec_helper'

class FakeHttpFetchCapture
  class << self
    attr_accessor :captured
  end

  def initialize(url, post)
    self.class.captured = { url: url, post: post, opts: nil }
  end

  def http_options=(opts)
    self.class.captured[:opts] = opts
  end

  def send
    {
      'response' => { 'results' => [{ 'status' => { 'errorcode' => 0 }, 'actionid' => OnOfficeSDK::SDK::ACTION_ID_READ,
                                      'resourcetype' => 'estate', 'data' => [] }] }
    }.to_json
  end
end

class SimpleCache
  include OnOfficeSDK::Cache::Interface
  def initialize
    @hit = false
  end

  def get_http_response_by_parameter_array(_)
    @hit ? '{"response":true}' : nil
  end

  def write(_p, _v)
    @hit = true
    true
  end

  def cleanup; end

  def clear_all
    @hit = false
  end
end

RSpec.describe OnOfficeSDK::SDK do
  it 'passes http options to fetcher when not provided and supports set_* wrappers' do
    sdk = described_class.new
    sdk.set_api_server('https://example.test/base/')
    sdk.set_api_version('myver')
    sdk.set_http_options(open_timeout: 5, read_timeout: 10)

    # Replace HttpFetch class to capture options
    stub_const('OnOfficeSDK::Internal::HttpFetch', FakeHttpFetchCapture)

    handle = sdk.call_generic(described_class::ACTION_ID_READ, 'estate', { 'data' => [] })
    sdk.send_requests('tok', 'sec') # http_fetch is nil -> SDK uses HttpFetch

    expect(FakeHttpFetchCapture.captured[:url]).to eq('https://example.test/base/myver/api.php')
    expect(FakeHttpFetchCapture.captured[:opts]).to eq(open_timeout: 5, read_timeout: 10)
    expect(sdk.get_response_array(handle)).to be_a(Hash)
  end

  it 'set_caches and remove_cache_instances work' do
    sdk = described_class.new
    sdk.set_api_server('https://api.onoffice.de/api/')
    sdk.set_api_version('stable')
    cache = SimpleCache.new
    sdk.set_caches([cache])

    # First call writes to cache (response []), then removing caches forces HTTP again
    stub_const('OnOfficeSDK::Internal::HttpFetch', FakeHttpFetchCapture)
    h1 = sdk.call_generic(described_class::ACTION_ID_READ, 'estate', { 'data' => [] })
    sdk.send_requests('tok', 'sec')
    sdk.get_response_array(h1)

    sdk.remove_cache_instances
    h2 = sdk.call_generic(described_class::ACTION_ID_READ, 'estate', { 'data' => [] })
    sdk.send_requests('tok', 'sec')
    expect(sdk.get_response_array(h2)).to be_a(Hash)
  end

  it 'handles nil http options by passing empty hash' do
    sdk = described_class.new
    sdk.set_api_server('https://example.test/base/')
    sdk.set_api_version('vX')
    sdk.set_http_options(nil)

    stub_const('OnOfficeSDK::Internal::HttpFetch', FakeHttpFetchCapture)
    h = sdk.call_generic(described_class::ACTION_ID_READ, 'estate', { 'data' => [] })
    sdk.send_requests('tok', 'sec')
    expect(FakeHttpFetchCapture.captured[:opts]).to eq({})
    expect(sdk.get_response_array(h)).to be_a(Hash)
  end
end
