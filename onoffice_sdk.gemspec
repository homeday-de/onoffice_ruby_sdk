# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "onoffice_sdk"
  version_rb = File.read(File.expand_path('lib/onoffice_sdk/version.rb', __dir__))
  spec.version       = version_rb.match(/VERSION\s*=\s*['\"]([^'\"]+)['\"]/)[1]
  spec.authors       = ['Henrique Feitosa']
  spec.email         = ['henrique.feitosa@homeday.de']

  spec.summary       = 'Ruby client for the onOffice API'
  spec.description   = 'Lightweight Ruby client to communicate with the onOffice API, supporting batched requests, HMAC signing, and pluggable caching.'
  spec.homepage      = 'https://apidoc.onoffice.de/'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    Dir['lib/**/*', 'README.md', 'LICENSE*'].select { |f| File.file?(f) }
  end
  spec.require_paths = ['lib']

  # Metadata intentionally minimal to avoid referencing external SDK repos

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'json', '>= 2.0'
  # No hard HTTP dep: uses stdlib Net::HTTP

  # Dev/test dependencies
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'rubocop', '~> 1.48'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.20'
end
