# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OnOfficeSDK::Internal::ApiAction do
  it 'produces a deterministic identifier' do
    a1 = described_class.new('act', 'estate', { 'b' => 2, 'a' => 1 })
    a2 = described_class.new('act', 'estate', { 'a' => 1, 'b' => 2 })
    expect(a1.identifier).to eq(a2.identifier)
  end
end
