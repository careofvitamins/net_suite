# frozen_string_literal: true

describe NetSuite::Configuration do
  let(:oauth) { double(:oauth) }
  let(:restlet) { double(:restlet) }
  let(:logger) { double(:logger) }

  shared_examples 'key error' do |key|
    it "raises a KeyError with #{key}" do
      expect { subject }.to raise_error(KeyError, /#{key}/)
    end
  end

  describe 'required arguments' do
    context 'when everything is included' do
      subject { described_class.new(oauth:, restlet:, logger:) }

      it 'returns a configuration object with the included arguments' do
        expect(subject).to have_attributes(oauth:, restlet:, logger:)
      end
    end

    context 'when oauth is missing' do
      subject { described_class.new(restlet:, logger:) }

      it_behaves_like 'key error', ':oauth'
    end

    context 'when restlet is missing' do
      subject { described_class.new(oauth:, logger:) }

      it_behaves_like 'key error', ':restlet'
    end

    context 'when logger is missing' do
      subject { described_class.new(oauth:, restlet:) }

      it_behaves_like 'key error', ':logger'
    end
  end

  context 'optional arguments' do
    describe 'log_requests' do
      context 'when log_requests is missing' do
        subject { described_class.new(oauth:, restlet:, logger:) }

        it 'is configured with false as default' do
          expect(subject.log_requests).to eq(false)
        end
      end

      context 'when log_requests is included' do
        subject { described_class.new(oauth:, restlet:, logger:, log_requests: :something) }

        it 'is configured with the provided value' do
          expect(subject.log_requests).to eq(:something)
        end
      end
    end

    describe 'trace_requests' do
      context 'when trace_requests is missing' do
        subject { described_class.new(oauth:, restlet:, logger:) }

        it 'is configured with false as default' do
          expect(subject.trace_requests).to eq(false)
        end
      end

      context 'when trace_requests is included' do
        subject { described_class.new(oauth:, restlet:, logger:, trace_requests: :something) }

        it 'is configured with the provided value' do
          expect(subject.trace_requests).to eq(:something)
        end
      end
    end

    describe 'request_timeout' do
      context 'when request_timeout is missing' do
        subject { described_class.new(oauth:, restlet:, logger:) }

        it 'is configured with 120 as default' do
          expect(subject.request_timeout).to eq(120)
        end
      end

      context 'when request_timeout is included' do
        subject { described_class.new(oauth:, restlet:, logger:, request_timeout: :something) }

        it 'is configured with the provided value' do
          expect(subject.request_timeout).to eq(:something)
        end
      end
    end
  end

  describe NetSuite::Configuration::OAuth do
    let(:api_host) { double(:api_host) }
    let(:client_id) { double(:client_id) }
    let(:certificate_id) { double(:certificate_id) }
    let(:certificate_private_key) { double(:certificate_private_key) }
    let(:cache) { double(:cache) }

    describe 'required arguments' do
      context 'when everything is included' do
        subject { described_class.new(api_host:, client_id:, certificate_id:, certificate_private_key:, cache:) }

        it 'returns a configuration object with the included arguments' do
          expect(subject).to have_attributes(api_host:, client_id:, certificate_id:, certificate_private_key:, cache:)
        end
      end

      context 'when api_host is missing' do
        subject { described_class.new(client_id:, certificate_id:, certificate_private_key:, cache:) }

        it_behaves_like 'key error', :api_host
      end

      context 'when client_id is missing' do
        subject { described_class.new(api_host:, certificate_id:, certificate_private_key:, cache:) }

        it_behaves_like 'key error', :client_id
      end

      context 'when certificate_id is missing' do
        subject { described_class.new(api_host:, client_id:, certificate_private_key:, cache:) }

        it_behaves_like 'key error', :certificate_id
      end

      context 'when certificate_private_key is missing' do
        subject { described_class.new(api_host:, client_id:, certificate_id:, cache:) }

        it_behaves_like 'key error', :certificate_private_key
      end

      context 'when cache is missing' do
        subject { described_class.new(api_host:, client_id:, certificate_id:, certificate_private_key:) }

        it_behaves_like 'key error', :cache
      end
    end

    context 'optional arguments' do
      describe 'token_expiration' do
        context 'when token_expiration is missing' do
          subject { described_class.new(api_host:, client_id:, certificate_id:, certificate_private_key:, cache:) }

          it 'is configured with 3600 as default' do
            expect(subject.token_expiration).to eq(3600)
          end
        end

        context 'when token_expiration is included' do
          subject { described_class.new(api_host:, client_id:, certificate_id:, certificate_private_key:, cache:, token_expiration: 12) }

          it 'is configured with the provided value' do
            expect(subject.token_expiration).to eq(12)
          end
        end
      end
    end
  end

  describe NetSuite::Configuration::Restlet do
    let(:api_host) { double(:api_host) }

    describe 'required arguments' do
      context 'when everything is included' do
        subject { described_class.new(api_host:) }

        it 'returns a configuration object with the included arguments' do
          expect(subject).to have_attributes(api_host:)
        end
      end

      context 'when api_host is missing' do
        subject { described_class.new }

        it_behaves_like 'key error', :api_host
      end
    end

    context 'optional arguments' do
      describe 'path' do
        context 'when path is missing' do
          subject { described_class.new(api_host:) }

          it 'is configured with default value' do
            expect(subject.path).to eq('app/site/hosting/restlet.nl')
          end
        end

        context 'when path is included' do
          subject { described_class.new(api_host:, path: '/something') }

          it 'is configured with the provided value' do
            expect(subject.path).to eq('/something')
          end
        end
      end
    end
  end
end
