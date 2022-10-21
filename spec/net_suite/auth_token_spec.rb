# frozen_string_literal: true

require 'active_support/testing/time_helpers'

describe NetSuite::AuthToken do
  include ActiveSupport::Testing::TimeHelpers

  subject { described_class.call(oauth_config, skip_cache:) }

  before { travel_to(current_time) }

  let(:current_time) { Time.new(2022, 10, 21, 12, 10) }

  let(:oauth_config) do
    NetSuite::Configuration::OAuth.new(
      api_host: 'http://oauth.example.com',
      client_id: 'a_client_id',
      certificate_id: public_key,
      certificate_private_key: private_key,
      cache:,
      token_expiration:,
    )
  end

  let(:skip_cache) { false }

  let(:cache) { double(:cache) }
  let(:token_expiration) { 300 }

  let(:key) { OpenSSL::PKey.generate_key('RSA', rsa_keygen_bits: 4096) }

  let(:public_key) { key.public_key.to_s }
  let(:private_key) { key.to_s }

  let(:jwt_value) do
    JWT.encode(jwt_payload, OpenSSL::PKey.read(private_key), 'RS512', { kid: public_key })
  end

  let(:jwt_payload) do
    {
      aud: 'http://oauth.example.com/services/rest/auth/oauth2/v1/token',
      iss: 'a_client_id',
      scope: 'restlets,rest_webservices',
      iat: current_time.to_i,
      exp: current_time.to_i + token_expiration,
    }
  end

  shared_examples 'new token fetched from API' do |warns_on_missing_token: false|
    let(:request_body) do
      {
        client_assertion: jwt_value,
        client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
        grant_type: 'client_credentials',
      }
    end

    let(:token_response) do
      {
        access_token: new_token_value,
        expires_at: current_time.to_i + token_expiration,
        refresh_token: nil,
        token_type: 'Bearer',
      }
    end

    let(:new_token_value) { 'bbbbbbbbb222222222' }
    let(:new_expires_at) { current_time.to_i + token_expiration }

    before do
      allow(cache).to receive(:write)

      stub_request(:post, 'http://oauth.example.com/services/rest/auth/oauth2/v1/token')
        .with(body: request_body)
        .to_return(status: 200, body: token_response.to_json, headers: { content_type: 'application/json' })
    end

    it 'fetches a new token from the API and writes to the cache' do
      if warns_on_missing_token
        expect do
          expect(subject).to eq(new_token_value)
        end.to output(/has no token/).to_stderr
      else
        expect do
          expect(subject).to eq(new_token_value)
        end.not_to output.to_stderr
      end
    end

    it 'writes the token to the cache' do
      expect(cache).to receive(:write).with('net_suite_oauth_access_token', token_response, expires_in: token_expiration)

      if warns_on_missing_token
        expect { subject }.to output(/has no token/).to_stderr
      else
        expect { subject }.not_to output.to_stderr
      end
    end
  end

  shared_examples 'cached token used' do
    it 'returns the token from the cache' do
      expect(subject).to eq(token_value)
    end

    it 'does not write the token to the cache' do
      expect(cache).not_to receive(:write)

      subject
    end
  end

  context 'when skip_cache is false' do
    let(:skip_cache) { false }

    context 'when the serialized OAuth2::AccessToken is present in the cache' do
      before { expect(cache).to receive(:read).and_return(cached_token) }

      let(:cached_token) do
        {
          access_token: token_value,
          expires_at: expires_at.to_i,
          refresh_token: nil,
          token_type: 'Bearer',
        }
      end

      let(:client) do
        OAuth2::Client.new(
          nil,
          nil,
          site: oauth_config.api_host,
          token_url: '/services/rest/auth/oauth2/v1/token',
          raise_errors: false,
        )
      end

      let(:token_value) { 'aaaaaaaaa111111111' }
      let(:expires_at) { current_time + 10.days }

      context 'when the serialized OAuth2::AccessToken in the cache is missing a token' do
        let(:token_value) { nil }

        it_behaves_like 'new token fetched from API', warns_on_missing_token: true
      end

      context 'when the serialized OAuth2::AccessToken in the cache has a token' do
        let(:token_value) { 'abcdefghij1234567890' }

        context 'when the token is expired' do
          let(:expires_at) { current_time - 10.days }

          it_behaves_like 'new token fetched from API', warns_on_missing_token: false
        end

        context 'when the token is not expired' do
          let(:expires_at) { current_time + 10.days }

          it_behaves_like 'cached token used'
        end
      end
    end
  end

  context 'when skip_cache is true' do
    let(:skip_cache) { true }

    before { expect(cache).not_to receive(:read) }

    it_behaves_like 'new token fetched from API', warns_on_missing_token: false
  end
end
