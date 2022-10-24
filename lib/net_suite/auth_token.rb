# frozen_string_literal: true

require 'oauth2'
require 'jwt'

module NetSuite
  class AuthToken
    method_object :oauth_config, [{ skip_cache: false }]

    def call
      unless skip_cache
        token = fetch_cached_token

        return token if token
      end

      new_token = client.client_credentials.get_token(token_params)

      write_token_to_cache(new_token)

      new_token.token
    end

    delegate(
      :api_host,
      :client_id,
      :certificate_id,
      :certificate_private_key,
      :token_expiration,
      :cache,
      to: :oauth_config,
      private: true,
    )

    private

    def expiration
      token_expiration&.to_i || 3600
    end

    ALGORITHM = 'RS512'
    TOKEN_URL = 'services/rest/auth/oauth2/v1/token'
    CACHE_KEY = 'net_suite_oauth_access_token'

    def write_token_to_cache(token)
      return unless cache.present?

      cache&.write(CACHE_KEY, token.to_hash, expires_in: token_expiration)
    end

    def fetch_cached_token
      return unless cache.present?

      hash_token = cache&.read(CACHE_KEY)

      return unless hash_token

      access_token = OAuth2::AccessToken.from_hash(client, hash_token)
      validated_cached_access_token(access_token)
    end

    def validated_cached_access_token(access_token)
      return unless access_token.token.present?
      return if access_token.expired?

      access_token.token
    end

    def token_params
      {
        client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
        client_assertion: jwt,
      }
    end

    def jwt
      JWT.encode(jwt_payload, key_pair, ALGORITHM, jwt_additional_header_fields)
    end

    def jwt_payload
      time = Time.now.to_i

      {
        aud: File.join(api_host, TOKEN_URL), # NetSuite token endpoint
        iss: client_id,                      # The Client ID for the integration
        scope: 'restlets,rest_webservices',  # restlets, rest_webservices, suite_analytics, or all of them, separated by a comma.
        iat: time,                           # Unix timestamp of token issuance
        exp: time + token_expiration,        # Unix timestamp of token expiration. Cannot be greater than iat + 3600
      }
    end

    def jwt_additional_header_fields
      {
        kid: certificate_id, # Certificate Id generated in the Oauth 2.0 client credentials mapping
      }
    end

    def key_pair
      OpenSSL::PKey.read(certificate_private_key)
    end

    def client
      @client ||= OAuth2::Client.new(
        nil,
        nil,
        site: api_host,
        token_url: TOKEN_URL,
        raise_errors: false,
      )
    end
  end
end
