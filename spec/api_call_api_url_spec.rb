# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OnOfficeSDK::Internal::ApiCall do
  it 'builds api_url with trailing slash' do
    api = described_class.new
    api.set_server('https://example.test/base/')
    api.set_api_version('v1')
    url = api.send(:api_url)
    expect(url).to eq('https://example.test/base/v1/api.php')
  end

  it 'builds api_url without trailing slash' do
    api = described_class.new
    api.set_server('https://example.test/base')
    api.set_api_version('v1')
    url = api.send(:api_url)
    expect(url).to eq('https://example.test/base/v1/api.php')
  end

  it 'raises when server not set' do
    api = described_class.new
    expect { api.send(:api_url) }.to raise_error(OnOfficeSDK::SDKError)
  end
end
