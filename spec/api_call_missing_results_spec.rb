# frozen_string_literal: true

require 'spec_helper'

class FakeHttpFetchNoResults
  def http_options=(opts)
    @opts = opts
  end

  def send
    { 'response' => {} }.to_json
  end
end

RSpec.describe OnOfficeSDK::Internal::ApiCall do
  it 'raises HttpFetchNoResultError when results are missing' do
    api = described_class.new
    api.set_server('https://api.onoffice.de/api/')
    api.set_api_version('stable')

    api.call_by_raw_data(OnOfficeSDK::SDK::ACTION_ID_READ, '', '', 'estate', { 'data' => [] })
    expect { api.send_requests('tok', 'sec', FakeHttpFetchNoResults.new) }
      .to raise_error(OnOfficeSDK::HttpFetchNoResultError)
  end
end
