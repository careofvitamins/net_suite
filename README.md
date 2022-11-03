# NetSuite

Care/of’s gem for working with NetSuite’s API and OAuth 2.0 authentication

## Installation

Add this line to your Gemfile:

```ruby
gem 'net_suite', github: 'careofvitamins/net_suite'
```

## Usage

Generate a configuration object:

```ruby
config = NetSuite::Configuration.new(
  oauth: NetSuite::Configuration::OAuth.new(
    api_host: 'https://netsuite-oauth.example.com',
    client_id: 'a_client_id',
    certificate_id: 'CERTIFICATE_ID',
    certificate_private_key: 'PRIVATE_KEY',
    cache: Rails.cache,
  ),
  restlet: NetSuite::Configuration::Restlet.new(
    api_host: 'https://netsuite-restlet.example.com',
  ),
  logger: Rails.logger,
  log_requests: true,
  datadog_request_tracing: true,
  request_timeout: 30,
)
```

Make a request using a restlet:

```ruby
restlet = NetSuite::Restlet.new(config)
body = { a: 1 }
restlet.post(body, script: 'script-id', deploy: 'deploy-id')
```

## Copyright

&copy; 2022 Care/of Vitamins
