# frozen_string_literal: true

module NetSuite
  class Configuration
    rattr_initialize [
      :oauth!,
      :restlet!,
      :logger!,
      {
        log_requests: false,
        request_timeout: 120,
      },
    ]

    alias log_requests? log_requests

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
