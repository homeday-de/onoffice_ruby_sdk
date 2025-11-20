# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OnOfficeSDK::Internal::Request do
  it 'fills timestamp and hmac fields when creating request' do
    action = OnOfficeSDK::Internal::ApiAction.new(
      OnOfficeSDK::SDK::ACTION_ID_READ,
      'estate',
      { 'data' => ['Id'] }
    )
    req = described_class.new(action)
    params = req.create_request('TOKEN', 'SECRET')
    expect(params['timestamp']).to be_a(Integer)
    expect(params['hmac_version']).to eq(2)
    expect(params['hmac']).to be_a(String)
  end

  it 'keeps provided timestamp when present' do
    ts = 1_650_000_000
    action = OnOfficeSDK::Internal::ApiAction.new(
      OnOfficeSDK::SDK::ACTION_ID_READ,
      'estate',
      { 'data' => ['Id'] },
      '',
      '',
      ts
    )
    req = described_class.new(action)
    params = req.create_request('TOKEN', 'SECRET')
    expect(params['timestamp']).to eq(ts)
  end
end
