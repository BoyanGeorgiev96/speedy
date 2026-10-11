# frozen_string_literal: true

require 'faraday'
require 'json'
require 'logger'

module Speedy
  class Client
    include Speedy::ClientResources

    class << self
      attr_reader :instance

      def configure
        @instance ||= new
        yield(@instance) if block_given?
        @instance.setup_connection!
      end

      def connection
        instance&.connection || raise('Speedy::Client is not configured. Call Speedy::Client.configure first.')
      end
    end

    attr_accessor :username, :password, :base_url, :adapter,
                  :language, :client_system_id,
                  :acronyms, :replace_acronym_defaults,
                  :debug, :debug_bodies, :debug_logger,
                  :open_timeout, :read_timeout, :write_timeout

    def initialize
      @base_url = 'https://api.speedy.bg/v1/'
      @adapter = Faraday.default_adapter
      @language = nil
      @client_system_id = nil
      @acronyms = {}
      @replace_acronym_defaults = false
      @debug = false
      @debug_bodies = false
      @debug_logger = Logger.new($stdout)
      @open_timeout = 30
      @read_timeout = 30
      @write_timeout = 30
    end

    def add_acronyms(hash)
      @acronyms = (@acronyms || {}).merge(hash.transform_keys(&:to_s))
    end

    def setup_connection!
      validate_credentials!

      @connection = Faraday.new(base_url) do |conn|
        configure_timeouts(conn)
        conn.use Speedy::CamelCaseMiddleware,
                 acronyms: @acronyms,
                 replace_defaults: @replace_acronym_defaults
        conn.request :json
        conn.response :json, content_type: 'application/json'
        configure_debug_logging(conn) if debug
        conn.adapter(*Array(adapter))
        conn.headers['User-Agent'] = "SpeedyRubyClient/#{Speedy::VERSION}"
      end
    end

    def connection
      @connection || raise('Connection is not initialized. Call Speedy::Client.configure first.')
    end

    def credentials
      {
        user_name: username,
        password: password,
        language: language,
        client_system_id: client_system_id
      }.compact
    end

    private

    def configure_debug_logging(connection)
      connection.response :logger, debug_logger, bodies: debug_bodies do |formatter|
        [username, password, client_system_id].each do |value|
          formatter.filter(value.to_s, '[FILTERED]') unless value.to_s.empty?
        end
      end
    end

    def configure_timeouts(connection)
      connection.options.open_timeout = open_timeout
      connection.options.timeout = read_timeout
      connection.options.write_timeout = write_timeout if connection.options.respond_to?(:write_timeout=)
    end

    def validate_credentials!
      creds_missing = [username, password].any? { |credential| credential.to_s.empty? }
      raise 'Username and password must be set' if creds_missing
    end
  end
end
