# frozen_string_literal: true

require 'bundler/setup'
require 'rspec'
begin
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    enable_coverage(:branch) if respond_to?(:enable_coverage)
    track_files 'lib/**/*.rb'
    SimpleCov.coverage_dir File.expand_path('../coverage', __dir__)
  end
rescue LoadError
  warn 'SimpleCov not available; coverage disabled'
end

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'onoffice_sdk'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
