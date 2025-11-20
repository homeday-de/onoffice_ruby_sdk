# frozen_string_literal: true

require 'spec_helper'

class MissCache
  include OnOfficeSDK::Cache::Interface
  def initialize(*); end

  def get_http_response_by_parameter_array(_)
    nil
  end

  def write(*)
    true
  end

  def cleanup; end
  def clear_all; end
end

class HitCache
  include OnOfficeSDK::Cache::Interface
  def initialize(*); end

  def get_http_response_by_parameter_array(_)
    { 'actionid' => OnOfficeSDK::SDK::ACTION_ID_READ, 'resourcetype' => 'estate', 'data' => [{ 'Id' => 7 }],
      'cacheable' => false }.to_json
  end

  def write(*)
    true
  end

  def cleanup; end
  def clear_all; end
end

RSpec.describe OnOfficeSDK::Internal::ApiCall do
  it 'fetches from the first cache that hits' do
    api = described_class.new
    api.set_server('https://api.onoffice.de/api/')
    api.set_api_version('stable')
    api.add_cache(MissCache.new)
    api.add_cache(HitCache.new)

    handle = api.call_by_raw_data(OnOfficeSDK::SDK::ACTION_ID_READ, '', '', 'estate', { 'data' => [] })
    # No HTTP provided -> should be satisfied from cache
    api.send_requests('tok', 'sec')
    resp = api.get_response(handle)
    expect(resp.dig('data', 0, 'Id')).to eq(7)
  end
end
