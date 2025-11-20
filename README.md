# onoffice_sdk (Ruby)

Ruby client for the onOffice API.

- HTTP over TLS
- Token + HMAC (v2) signing per action
- Batched requests
- Pluggable cache hooks

## Install

Build and install locally:

```
gem build onoffice_sdk.gemspec
gem install onoffice_sdk-*.gem
```

Add to your Gemfile:

```
# For local development using this repo
gem 'onoffice_sdk', path: '.'

# Or use the released gem
# gem 'onoffice_sdk', '~> 0.x'
```

## Quickstart

```ruby
require 'onoffice_sdk'

sdk = OnOfficeSDK::SDK.new
sdk.set_api_version('stable')

parameters_read_estate = {
  'data' => ['Id', 'kaufpreis', 'lage'],
  'listlimit' => 10,
  'sortby' => { 'kaufpreis' => 'ASC', 'warmmiete' => 'ASC' },
  'filter' => {
    'kaufpreis' => [{ 'op' => '>', 'val' => 300_000 }],
    'status' => [{ 'op' => '=', 'val' => 1 }]
  }
}

handle = sdk.call_generic(OnOfficeSDK::SDK::ACTION_ID_READ, 'estate', parameters_read_estate)

sdk.send_requests('PUT_TOKEN_HERE', 'PUT_SECRET_HERE')

p sdk.get_response_array(handle)
```

## API

- `set_api_version(version)` – sets API version (default: `stable`).
- `set_api_server(url)` – sets base server (default: `https://api.onoffice.de/api/`).
- `set_http_options(hash)` – Net::HTTP options, e.g., `{ open_timeout: 5, read_timeout: 30 }`.
- `call_generic(action_id, resource_type, parameters)` – queue an action.
- `call(action_id, resource_id, identifier, resource_type, parameters)` – queue an action with explicit identifiers.
- `send_requests(token, secret)` – send all queued actions in a single HTTP request.
- `get_response_array(handle)` – fetch and remove the response for a prior handle.
- `add_cache(cache)` / `set_caches([...])` – register cache backends.
- `remove_cache_instances` – clear all registered caches.
- `errors` – returns a hash of errors for failed actions.

### Cache interface

Implementors should respond to:

```ruby
class MyCache
  include OnOfficeSDK::Cache::Interface

  def initialize(options = {}); end
  def get_http_response_by_parameter_array(parameters); end # -> String (JSON) or nil
  def write(parameters, value); end                          # value is a JSON string
  def cleanup; end
  def clear_all; end
end
```

When a response is cacheable, the SDK writes a JSON string of the response payload to caches. Reads should return that JSON string for a hit.

## Notes

- HMAC v2 implemented as Base64.strict_encode64(HMAC-SHA256(secret, timestamp + token + resourcetype + actionid)).
- Batch request body shape: `{ token, request: { actions: [...] } }`.
- Response handling uses `status.errorcode`, `data`, and `cacheable`.

## License

MIT (see repository LICENSE).

## Rails Integration

The gem includes a Railtie for auto-configuration, an optional Rails.cache adapter, and a generator.

1) Gemfile

```
# For local development using this repo
gem 'onoffice_sdk', path: '.'

# Or use the released gem
# gem 'onoffice_sdk', '~> 0.x'
```

2) Credentials or ENV

Set `ONOFFICE_TOKEN` and `ONOFFICE_SECRET` (or use Rails credentials):

```
# .env or deployment env
ONOFFICE_TOKEN=your_token
ONOFFICE_SECRET=your_secret
ONOFFICE_API_VERSION=stable
ONOFFICE_API_BASE=https://api.onoffice.de/api/
```

3) Initializer (auto-config via Railtie or generator)

```ruby
OnOfficeSDK.configure do |c|
  # c.api_server = ENV.fetch('ONOFFICE_API_BASE', 'https://api.onoffice.de/api/')
  # c.api_version = ENV.fetch('ONOFFICE_API_VERSION', 'stable')
  # c.open_timeout = 5
  # c.read_timeout = 30
  # c.token = Rails.application.credentials.dig(:onoffice, :token)
  # c.secret = Rails.application.credentials.dig(:onoffice, :secret)
  # c.use_rails_cache = true
  # c.rails_cache_ttl = 600
end
```

4) Use the generator (optional)

```
bin/rails g onoffice_sdk:install
```

This creates `config/initializers/onoffice_sdk.rb` and `app/services/onoffice_client.rb`.

5) Example service (app/services/onoffice_client.rb)

```ruby
class OnofficeClient
  def initialize(sdk: OnOfficeSDK.client)
    @sdk = sdk
  end

  def read_estates(limit: 10)
    params = { 'data' => ['Id', 'kaufpreis'], 'listlimit' => limit }
    handle = @sdk.call_generic(OnOfficeSDK::SDK::ACTION_ID_READ, 'estate', params)
    @sdk.send_requests(token, secret)
    @sdk.get_response_array(handle)
  end

  private

  def token
    ENV.fetch('ONOFFICE_TOKEN')
  end

  def secret
    ENV.fetch('ONOFFICE_SECRET')
  end
end
```

5) Use in a controller

```ruby
class EstatesController < ApplicationController
  def index
    @result = OnofficeClient.new.read_estates(limit: 10)
  end
end
```

6) Optional: Rails.cache adapter

```ruby
require 'digest/md5'

Built-in: `OnOfficeSDK::Cache::RailsCache`.

```ruby
# In the initializer
# OnOfficeSDK.configure do |c|
#   c.use_rails_cache = true
#   c.rails_cache_ttl = 10.minutes
# end
```

Notes for Rails
- The client is stateless; create once and reuse per-process or inject per-request.
- `send_requests(token, secret)` batches all queued actions; queue multiple calls, then send once.
- Cache interface expects JSON strings; example above writes/reads raw strings to `Rails.cache`.
- ActiveSupport::Notifications: emits `onoffice_sdk.request` around each HTTP call.
