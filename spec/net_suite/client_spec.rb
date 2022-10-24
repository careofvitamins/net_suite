# frozen_string_literal: true

describe NetSuite::Client do
  let(:instance) { described_class.new(config) }

  let(:config) do
    NetSuite::Configuration.new(
      oauth: oauth_config,
      restlet: restlet_config,
      logger:,
      log_requests:,
      request_timeout:,
    )
  end

  let(:oauth_config) do
    ::NetSuite::Configuration::OAuth.new(
      api_host: 'http://oauth.example.com',
      client_id: 'a_client_id',
      certificate_id: 'aaaaaaaaaaaa',
      certificate_private_key: 'bbbbbbbbbbbb',
      cache:,
      token_expiration:,
    )
  end

  let(:cache) { double(:cache) }
  let(:token_expiration) { 300 }

  let(:restlet_config) do
    NetSuite::Configuration::Restlet.new(
      api_host: 'http://restlet.example.com',
      path: '/restlet',
    )
  end

  let(:logger) { double(:logger) }

  before do
    %i[debug info warn error].each do |method|
      allow(logger).to receive(method)
    end
  end

  let(:log_requests) { true }
  let(:request_timeout) { 30 }

  let(:path) { '/some_path' }
  let(:body) { { 'a' => 'b' } }
  let(:params) { {} }
  let(:headers) { {} }

  let(:url) { 'http://restlet.example.com/some_path' }

  let(:initial_response_status) { 200 }
  let(:initial_response_body) { { 'success' => true } }
  let(:initial_request_token) { 'valid_token' }

  let(:subsequent_response_status) { 200 }
  let(:subsequent_response_body) { { 'success' => true } }
  let(:subsequent_request_token) { 'other_token' }

  let(:request_method) { :get }

  shared_examples 'requests handled properly' do |method:|
    before do
      allow(NetSuite::AuthToken)
        .to receive(:call)
        .with(oauth_config, skip_cache: false)
        .and_return(initial_request_token)
        .once

      allow(NetSuite::AuthToken)
        .to receive(:call)
        .with(oauth_config, skip_cache: true)
        .and_return(subsequent_request_token)
        .once
    end

    before do
      stub_request(
        method,
        'http://restlet.example.com/some_path',
      ).with(
        headers: { 'Authorization' => "Bearer #{initial_request_token}" },
      ).to_return(
        status: initial_response_status,
        body: initial_response_body.to_json,
        headers: { content_type: 'application/json' },
      )

      stub_request(
        method,
        'http://restlet.example.com/some_path',
      ).with(
        headers: { 'Authorization' => "Bearer #{subsequent_request_token}" },
      ).to_return(
        status: subsequent_response_status,
        body: subsequent_response_body.to_json,
        headers: { content_type: 'application/json' },
      )
    end

    shared_examples 'one request' do |status:|
      it 'makes the request once' do
        subject

        expect(a_request(method, url)).to have_been_made.once
      end

      it 'requests the auth token once' do
        expect(NetSuite::AuthToken).to receive(:call).with(oauth_config, skip_cache: false).once.and_return('valid_token')
        expect(NetSuite::AuthToken).not_to receive(:call).with(oauth_config, skip_cache: true)

        subject
      end

      it 'returns the response' do
        expect(subject).to have_attributes(status:, body: initial_response_body)
      end
    end

    shared_examples 'retried request' do |status:|
      let(:initial_request_token) { 'invalid_token' }
      let(:subsequent_request_token) { 'valid_token' }

      let(:initial_response_body) { { 'success' => false } }

      context 'when response is a 401' do
        let(:initial_response_status) { 401 }

        it 'makes the request twice' do
          subject

          expect(a_request(method, url)).to have_been_made.twice
        end

        it 'requests auth token twice' do
          expect(NetSuite::AuthToken).to receive(:call).with(oauth_config, skip_cache: false).once.and_return(initial_request_token)
          expect(NetSuite::AuthToken).to receive(:call).with(oauth_config, skip_cache: true).once.and_return(subsequent_request_token)

          subject
        end

        it 'returns the second response' do
          expect(subject).to have_attributes(status:, body: subsequent_response_body)
        end
      end
    end

    context 'when response is successful' do
      it_behaves_like 'one request', status: 200
    end

    context 'when response is a failure' do
      it_behaves_like 'retried request', status: 200

      context 'when response is not a 401' do
        let(:initial_response_status) { 500 }

        it_behaves_like 'one request', status: 500
      end
    end
  end

  describe 'query methods' do
    describe '#get' do
      subject { instance.get(path, params, headers) }

      it_behaves_like 'requests handled properly', method: :get
    end

    describe '#head' do
      subject { instance.head(path, params, headers) }

      it_behaves_like 'requests handled properly', method: :head
    end

    describe '#delete' do
      subject { instance.delete(path, params, headers) }

      it_behaves_like 'requests handled properly', method: :delete
    end
  end

  describe 'body methods' do
    let(:block) { ->(_request) { something.go } }
    let(:something) { double(:something) }

    before { expect(something).to receive(:go).at_least(:once) }

    describe '#post' do
      subject { instance.post(path, body, headers, &block) }

      it_behaves_like 'requests handled properly', method: :post
    end

    describe '#put' do
      subject { instance.put(path, body, headers, &block) }

      it_behaves_like 'requests handled properly', method: :put
    end

    describe '#patch' do
      subject { instance.patch(path, body, headers, &block) }

      it_behaves_like 'requests handled properly', method: :patch
    end
  end
end
