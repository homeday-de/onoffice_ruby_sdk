# frozen_string_literal: true

require 'spec_helper'

DummyReq = Struct.new(:request_id)

RSpec.describe OnOfficeSDK::Internal::Response do
  it 'valid? is true only when actionid, resourcetype, and data present' do
    req = DummyReq.new(1)
    r_ok = described_class.new(req, { 'actionid' => 'x', 'resourcetype' => 'y', 'data' => [] })
    expect(r_ok.valid?).to be true

    r_no_action = described_class.new(req, { 'resourcetype' => 'y', 'data' => [] })
    expect(r_no_action.valid?).to be false

    r_no_type = described_class.new(req, { 'actionid' => 'x', 'data' => [] })
    expect(r_no_type.valid?).to be false
  end

  it 'cacheable? requires valid? and cacheable flag' do
    req = DummyReq.new(2)
    r_not_valid = described_class.new(req, { 'cacheable' => true })
    expect(r_not_valid.cacheable?).to be false

    r_valid_false_flag = described_class.new(req,
                                             { 'actionid' => 'x', 'resourcetype' => 'y', 'data' => [],
                                               'cacheable' => false })
    expect(r_valid_false_flag.cacheable?).to be false
  end
end
