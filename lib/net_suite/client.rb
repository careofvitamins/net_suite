# frozen_string_literal: true

require 'faraday'

module NetSuite
  class Client
    rattr_initialize :config do
      @retry_count = 0
    end

    Faraday::METHODS_WITH_QUERY.each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        # def get(url = nil, params = nil, headers = nil)
        #   with_auth_retry do
        #     trace_call(__method__.to_s.upcase, url, nil) do
        #       connection.get(url, params, headers)
        #     end
        #   end
        # end

        def #{method}(url = nil, params = nil, headers = nil)
          with_auth_retry do
            trace_call(__method__.to_s.upcase, url, nil) do
              connection.#{method}(url, params, headers)
            end
          end
        end
      RUBY
    end

    Faraday::METHODS_WITH_BODY.each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        # def post(url = nil, body = nil, headers = nil, &block)
        #   with_auth_retry do
        #     trace_call(__method__.to_s.upcase, url, body) do
        #       connection.post(url, body, headers, &block)
        #     end
        #   end
        # end

        def #{method}(url = nil, body = nil, headers = nil, &block)
          with_auth_retry do
            trace_call(__method__.to_s.upcase, url, body) do
              connection.#{method}(url, body, headers, &block)
            end
          end
        end
      RUBY
    end

    private

    attr_accessor :retry_count

    def trace_call(method, url, request_payload, &)
      return yield unless datadog_request_tracing?

      Datadog::Tracing.trace("netsuite #{method}",
                             resource: "#{method} #{url}",
                             span_type: 'http',
                             service: 'netsuite',
                             tags: { method:, url:, request_payload:, async: async? },
                             &)
    end

    def with_auth_retry(&)
      initial_response = yield
      return initial_response if initial_response.success?
      return initial_response unless initial_response.status == 401

      self.retry_count += 1

      yield
    end

    def fetch_auth_token
      NetSuite::AuthToken.call(
        config.oauth,
        skip_cache: retry_count.positive?,
      )
    end

    def restlet_api_host
      config.restlet.api_host
    end

    def request_timeout
      config.request_timeout&.to_i || 120
    end

    def connection
      @connection ||= build_connection
    end

    def default_headers
      {
        content_type: 'application/json',
        accept: 'application/json',
      }
    end

    def request_options
      {
        timeout: request_timeout,
      }
    end

    def log_requests?
      config.logger && config.log_requests?
    end

    def datadog_request_tracing?
      defined?(Datadog::Tracing.trace) && config.datadog_request_tracing?
    end

    def async?
      defined?(Sidekiq.server?) && Sidekiq.server?
    end

    def build_connection
      Faraday.new(url: restlet_api_host, headers: default_headers, request: request_options) do |conn|
        conn.adapter Faraday.default_adapter

        conn.request :json
        conn.request :authorization, 'Bearer', -> { fetch_auth_token }
        conn.response :json, content_type: /\bjson$/

        configure_logging(conn)
      end
    end

    def configure_logging(connection)
      return unless log_requests?

      connection.response(
        :logger,
        config.logger,
        headers: true,
        bodies: true,
        log_level: config.log_level,
      )
    end
  end
end
