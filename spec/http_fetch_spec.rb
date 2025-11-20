# frozen_string_literal: true

require 'spec_helper'

class FakeOk < Net::HTTPSuccess
  def initialize
    super('1.1', '200', 'OK')
  end

  def body
    '{"ok":true}'
  end
end

class FakeFailResponse
  def code
    '500'
  end

  def body
    nil
  end
end

class FakeHTTP
  class << self
    attr_accessor :last_use_ssl
  end
  def use_ssl=(v)
    self.class.last_use_ssl = v
  end

  def open_timeout=(_v); end
  def read_timeout=(_v); end

  def request(_req)
    FakeOk.new
  end
end

class FakeHTTPFail
  def use_ssl=(_v); end
  def open_timeout=(_v); end
  def read_timeout=(_v); end

  def request(_req)
    FakeFailResponse.new
  end
end

RSpec.describe OnOfficeSDK::Internal::HttpFetch do
  it 'uses SSL for https URIs and returns body on success' do
    allow(Net::HTTP).to receive(:new).and_return(FakeHTTP.new)
    fetch = described_class.new('https://example.test/api', '{"x":1}')
    body = fetch.send
    expect(body).to include('ok')
    expect(FakeHTTP.last_use_ssl).to be true
  end

  it 'disables SSL for http URIs and raises on non-success' do
    allow(Net::HTTP).to receive(:new).and_return(FakeHTTPFail.new)
    fetch = described_class.new('http://example.test/api', '{"x":1}')
    expect { fetch.send }.to raise_error(OnOfficeSDK::HttpFetchNoResultError)
  end
end
