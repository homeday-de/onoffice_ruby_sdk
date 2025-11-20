# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OnOfficeSDK::Internal::Request do
  it 'computes HMAC v2 as specified' do
    action = OnOfficeSDK::Internal::ApiAction.new(
      OnOfficeSDK::SDK::ACTION_ID_READ,
      'estate',
      { 'data' => ['Id'] },
      '',
      '',
      1_700_000_000 # fixed timestamp
    )
    req = described_class.new(action)

    token = 'TOKEN123'
    secret = 'SECRET456'
    timestamp = 1_700_000_000
    expected = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', secret,
                                                           [timestamp,
                                                            token, 'estate',
                                                            OnOfficeSDK::SDK::ACTION_ID_READ].join))

    expect(req.create_hmac2(token, secret, timestamp, 'estate', OnOfficeSDK::SDK::ACTION_ID_READ)).to eq(expected)
  end
end
