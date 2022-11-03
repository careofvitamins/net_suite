# frozen_string_literal: true

module NetSuite
  class Configuration
    rattr_initialize [
      :oauth!,
      :restlet!,
      :logger!,
      {
        log_requests: false,
        datadog_request_tracing: false,
        request_timeout: 120,
      },
    ]

    alias log_requests? log_requests
    alias datadog_request_tracing? datadog_request_tracing

    class OAuth
      rattr_initialize [
        :api_host!,
        :client_id!,
        :certificate_id!,
        :certificate_private_key!,
        :cache!,
        {
          token_expiration: 3600,
        },
      ]
    end

    class Restlet
      rattr_initialize [
        :api_host!,
        {
          path: 'app/site/hosting/restlet.nl',
        },
      ]
    end
  end
end
