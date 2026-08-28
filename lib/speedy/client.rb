# frozen_string_literal: true

require 'faraday'
require 'json'
require 'logger'

module Speedy
  class Client
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
                  :debug

    def initialize
      @base_url = 'https://api.speedy.bg/v1/'
      @adapter = Faraday.default_adapter
      @language = nil
      @client_system_id = nil
      @acronyms = {}
      @replace_acronym_defaults = false
      @debug = false
    end

    def add_acronyms(hash)
      @acronyms = (@acronyms || {}).merge(hash.transform_keys(&:to_s))
    end

    def setup_connection!
      validate_credentials!

      @connection = Faraday.new(base_url) do |conn|
        conn.use Speedy::CamelCaseMiddleware,
                 acronyms: @acronyms,
                 replace_defaults: @replace_acronym_defaults
        conn.request :json
        conn.response :json, content_type: 'application/json'
        conn.response :logger, Logger.new($stdout), bodies: true if debug
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

    def calculate_delivery(**args)
      Speedy::Services::Calculation.new(client: self).calculate(**args)
    end

    alias calculate_delivery_fee calculate_delivery

    def create_shipment(**args)
      Speedy::Services::Shipments::Shipment.new(client: self).create(**args)
    end

    def print_labels(**args)
      Speedy::Services::Print.new(client: self).create_pdf_extended(**args)
    end

    def label_info(**args)
      Speedy::Services::Print.new(client: self).label_info(**args)
    end

    def find_sites(**args)
      Speedy::Services::Location::Site.new(client: self).find(**args)
    end

    def find_offices(**args)
      Speedy::Services::Location::Office.new(client: self).find(**args)
    end

    def validate_address(address)
      Speedy::Services::Validation::Address.new(client: self).validate_address(address)
    end

    private

    def validate_credentials!
      creds_missing = [username, password].any? { |cred| cred.nil? || cred.empty? }
      raise 'Username and password must be set' if creds_missing
    end
  end
end
