# frozen_string_literal: true

module Speedy
  class ServiceResource
    attr_reader :client

    class << self
      def resource_path(value = nil)
        return @resource_path unless value

        @resource_path = value
      end
    end

    ERROR_MESSAGES = {
      400 => 'Your request was malformed.',
      401 => 'You did not supply valid authentication credentials.',
      403 => 'You are not allowed to perform that action.',
      404 => 'No results were found for your request.',
      429 => 'Your request exceeded the API rate limit.',
      500 => 'We were unable to perform the request due to server-side problems.',
      503 => 'The Speedy API is currently unavailable.'
    }.freeze

    def initialize(client: Speedy::Client.instance)
      message = 'Speedy::Client is not configured. Call `Speedy::Client.configure` first.'

      @client = client || raise(message)
    end

    def resource_url
      self.class.resource_path
    end

    private

    def get(url = nil, params: {}, headers: {})
      response_for(with_transport_errors { client.connection.get(url_for(url), params, headers) })
    end

    def post(url = nil, body: nil, headers: {})
      response_for(with_transport_errors { client.connection.post(url_for(url), request_body(body), headers) })
    end

    def delete(url = nil, params: {}, headers: {})
      response_for(with_transport_errors { client.connection.delete(url_for(url), params, headers) })
    end

    def with_transport_errors
      yield
    rescue Faraday::TimeoutError => e
      raise TimeoutError, 'Speedy API request timed out.', cause: e
    rescue Faraday::ConnectionFailed => e
      raise ConnectionError, 'Could not connect to the Speedy API.', cause: e
    rescue Faraday::SSLError => e
      raise SSLError, 'Speedy API TLS connection failed.', cause: e
    end

    def url_for(url)
      [resource_url, url].compact.reject(&:empty?).join('/')
    end

    def request_body(body)
      client.credentials.merge(body || {})
    end

    def response_for(response)
      error = error_from(response.body)
      raise Error.new(error: error, status: response.status) if error && !successful_response?(response)

      error_message = ERROR_MESSAGES[response.status]
      raise Error.new(error_message, status: response.status) if error_message
      raise Error.new(status: response.status) unless successful_response?(response)

      response
    end

    def collection(response, model)
      model.collection(response.body)
    end

    def resource(response, model, key: nil)
      model.build(response.body, key: key)
    end

    def error_from(body)
      Speedy::Models::Error.build_from(body)
    end

    def successful_response?(response)
      response.status.to_i.between?(200, 299)
    end
  end
end
