# frozen_string_literal: true

describe NetSuite::Restlet do
  let(:instance) { described_class.new(config) }

  let(:config) { instance_double(NetSuite::Configuration, restlet: restlet_config) }

  let(:restlet_config) do
    NetSuite::Configuration::Restlet.new(
      api_host: 'http://restlet.example.com',
      path: '/restlet',
    )
  end

  let(:client) { instance_double(NetSuite::Client) }

  before do
    allow(NetSuite::Client).to receive(:new).with(config).and_return(client)
  end

  let(:script) { 'ascript' }
  let(:deploy) { 'adeploy' }
  let(:headers) { double(:headers) }

  describe 'query methods' do
    describe '#get' do
      subject { instance.get(script:, deploy:, headers:) }

      it 'calls the client with the correct paramaters' do
        expect(client).to receive(:get).with(restlet_config.path, { script:, deploy: }, headers)

        subject
      end
    end

    describe '#head' do
      subject { instance.head(script:, deploy:, headers:) }

      it 'calls the client with the correct paramaters' do
        expect(client).to receive(:head).with(restlet_config.path, { script:, deploy: }, headers)

        subject
      end
    end

    describe '#delete' do
      subject { instance.delete(script:, deploy:, headers:) }

      it 'calls the client with the correct paramaters' do
        expect(client).to receive(:delete).with(restlet_config.path, { script:, deploy: }, headers)

        subject
      end
    end
  end

  describe 'body methods' do
    let(:body) { double(:body) }
    let(:generated_path) { "/restlet?deploy=#{deploy}&script=#{script}" }

    describe '#post' do
      subject { instance.post(body, script:, deploy:, headers:) }

      it 'calls the client with the correct paramaters' do
        expect(client).to receive(:post).with(generated_path, body, headers)

        subject
      end
    end

    describe '#put' do
      subject { instance.put(body, script:, deploy:, headers:) }

      it 'calls the client with the correct paramaters' do
        expect(client).to receive(:put).with(generated_path, body, headers)

        subject
      end
    end

    describe '#patch' do
      subject { instance.patch(body, script:, deploy:, headers:) }

      it 'calls the client with the correct paramaters' do
        expect(client).to receive(:patch).with(generated_path, body, headers)

        subject
      end
    end
  end
end
