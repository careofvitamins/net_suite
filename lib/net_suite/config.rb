# frozen_string_literal: true

module NetSuite
  class Config
    rattr_initialize [
      :oauth!,
      :restlet!,
      {
        logger: nil,
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
      rattr_initialize %i[
        api_host!
      ]
    end
  end
end
