# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OnOfficeSDK::Internal::ApiCall do
  it 'returns nil when getting response for unknown handle' do
    api = described_class.new
    expect(api.get_response(999_999)).to be_nil
  end
end
