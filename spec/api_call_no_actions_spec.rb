# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OnOfficeSDK::Internal::ApiCall do
  it 'handles send_requests with no queued actions' do
    api = described_class.new
    api.set_server('https://api.onoffice.de/api/')
    api.set_api_version('stable')
    expect { api.send_requests('tok', 'sec') }.not_to raise_error
  end
end
