# frozen_string_literal: true

require 'faraday'

module NetSuite
  class Restlet
    rattr_initialize :config

    Faraday::METHODS_WITH_QUERY.each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        # def get(script:, deploy:, headers: nil)
        #   client.get(config.restlet.path, { script: script, deploy: deploy }, headers)
        # end

        def #{method}(script:, deploy:, headers: nil)
          client.#{method}(config.restlet.path, { script: script, deploy: deploy }, headers)
        end
      RUBY
    end

    Faraday::METHODS_WITH_BODY.each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        # def post(body = nil, script:, deploy:, headers: nil, &block)
        #   client.post(generate_path(script: script, deploy: deploy), body, headers, &block)
        # end

        def #{method}(body = nil, script:, deploy:, headers: nil, &block)
          client.#{method}(generate_path(script: script, deploy: deploy), body, headers, &block)
        end
      RUBY
    end

    private

    def generate_path(script:, deploy:)
      "#{config.restlet.path}?#{{ script:, deploy: }.to_query}"
    end

    def client
      @client ||= NetSuite::Client.new(config)
    end
  end
end
