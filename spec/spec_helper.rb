# frozen_string_literal: true

require 'date'
require 'dotenv'
require 'json'
require 'vcr'
require 'webmock/rspec'

replay_only = ENV['SPEEDY_VCR_REPLAY'] == '1' || ENV['CI'] == 'true'
Dotenv.load('.env.test', '.env') unless replay_only
WebMock.disable_net_connect! if replay_only

require 'speedy'
require_relative 'support/vcr_print_sanitizer'

module SpeedyVcrSanitizer
  extend SpeedyVcrPrintSanitizer

  MUTATION_CASSETTE = 'speedy_api/shipment_create_cancel_and_verify'
  MUTATION_CASSETTES = [
    MUTATION_CASSETTE,
    'speedy_api/shipment_update_and_cancel',
    'speedy_api/shipment_properties_and_cancel'
  ].freeze
  CREATED_SHIPMENT_PLACEHOLDER = '<SPEEDY_CREATED_SHIPMENT_ID>'
  PRINT_ENDPOINT = %r{/print(?:/extended|/voucher)?\z}
  REDACTED_PDF = "%PDF-1.4\n% REDACTED VCR DOCUMENT\n"
  ACCOUNT_ENDPOINT = %r{
    /client|/payout|/shipment|/track|/barcode|/print|
    /calculate|/services/destination
  }x
  SENSITIVE_KEY = /
    name|phone|email|address|street|quarter|block|entrance|floor|apartment|postCode|
    client|shipment|parcel|barcode|reference|ref\d*|
    amount|price|account|iban|bank|url|secret|(?:\A|_)(?:id)\z|ID\z
  /ix
  STRUCTURAL_KEY = /\A(?:parcelsCount|pendingParcels|pendingShipment)\z/i

  module_function

  def sanitize_mutation!(interaction)
    if interaction.request.uri.match?(%r{/shipment\z})
      response = parse_json(interaction.response.body.to_s.dup.force_encoding(Encoding::UTF_8))
      @created_shipment_id = response['id']
    end
    return if @created_shipment_id.to_s.empty?

    replace_in_bodies!(interaction, @created_shipment_id.to_s, CREATED_SHIPMENT_PLACEHOLDER)
    sanitize_response!(interaction)
  rescue JSON::ParserError
    nil
  end

  def sanitize_response!(interaction)
    return sanitize_print_response!(interaction) if interaction.request.uri.match?(PRINT_ENDPOINT)

    sanitize_json_response!(interaction)
  end

  def sanitize_json_response!(interaction)
    return unless interaction.request.uri.match?(ACCOUNT_ENDPOINT)

    body = interaction.response.body.to_s.dup.force_encoding(Encoding::UTF_8)
    return if body.empty? || !body.valid_encoding?

    interaction.response.body = JSON.pretty_generate(sanitize(parse_json(body)))
  rescue JSON::ParserError
    nil
  end

  def parse_json(body)
    JSON.parse(body)
  rescue JSON::ParserError
    normalized = body.gsub(/([:\[,]\s*)<[^>\r\n]+>(?=\s*[,}\]])/) do
      "#{Regexp.last_match(1)}0"
    end
    JSON.parse(normalized)
  end

  def sanitize(value, key = nil)
    return redact(value) if key&.match?(/phone/i)
    return redact(value) if sensitive_scalar?(key, value)

    case value
    when Hash
      value.to_h { |child_key, child_value| [child_key, sanitize(child_value, child_key)] }
    when Array
      value.map { |item| sanitize(item, key) }
    else
      value
    end
  end

  def sensitive_scalar?(key, value)
    key&.match?(SENSITIVE_KEY) && !key.match?(STRUCTURAL_KEY) && !value.is_a?(Hash) && !value.is_a?(Array)
  end

  def redact(value)
    return value if value == CREATED_SHIPMENT_PLACEHOLDER

    case value
    when Hash then value.transform_values { |item| redact(item) }
    when Array then value.map { |item| redact(item) }
    when Numeric then 0
    when true, false then false
    when nil then nil
    else '<REDACTED>'
    end
  end

  def replace_in_bodies!(interaction, value, placeholder)
    [interaction.request, interaction.response].each do |message|
      message.body = message.body.to_s.gsub(value, placeholder)
    end
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.default_cassette_options = {
    record: replay_only ? :none : :once,
    match_requests_on: %i[method uri body]
  }
  config.allow_http_connections_when_no_cassette = false
  config.before_http_request do |request|
    raise 'Replay-only mode blocks all unstubbed HTTP requests' if replay_only && !request.stubbed?
  end
  config.register_request_matcher :replay_body do |left, right|
    SpeedyVcrSanitizer.parse_json(left.body) == SpeedyVcrSanitizer.parse_json(right.body)
  end
  config.register_request_matcher :replay_uri do |left, right|
    left.uri.gsub('<SPEEDY_SENDER_CLIENT_ID>', '0') == right.uri.gsub('<SPEEDY_SENDER_CLIENT_ID>', '0')
  end

  %w[
    SPEEDY_USERNAME
    SPEEDY_PASSWORD
    SPEEDY_SENDER_NAME
    SPEEDY_SENDER_PHONE
    SPEEDY_SENDER_EMAIL
    SPEEDY_SENDER_CLIENT_ID
  ].each do |key|
    next if replay_only

    value = ENV.fetch(key, nil)
    config.filter_sensitive_data("<#{key}>") { value } unless value.to_s.empty?
  end

  %w[SPEEDY_CONTRACT_SHIPMENT_IDS SPEEDY_CONTRACT_PARCEL_IDS].each do |key|
    next if replay_only

    ENV.fetch(key, '').split(',').map(&:strip).reject(&:empty?).each_with_index do |value, index|
      config.filter_sensitive_data("<#{key}_#{index + 1}>") { value }
    end
  end

  %w[
    SPEEDY_CONTRACT_SHIPMENT_IDS
    SPEEDY_CONTRACT_PARCEL_IDS
    SPEEDY_CONTRACT_REFERENCE
    SPEEDY_CONTRACT_EXTERNAL_CONTACT_ID
    SPEEDY_CONTRACT_EXTERNAL_CONTACT_SECRET
  ].each do |key|
    next if replay_only

    value = ENV.fetch(key, nil)
    config.filter_sensitive_data("<#{key}>") { value } unless value.to_s.empty?
  end

  configured_date = ENV.fetch('SPEEDY_CONTRACT_DATE', '')
  contract_date = configured_date.empty? ? Date.today.iso8601 : configured_date
  config.filter_sensitive_data('<SPEEDY_CONTRACT_DATE>') { contract_date } unless replay_only

  config.before_record do |interaction, cassette|
    raise 'Recording is forbidden in replay-only mode' if replay_only

    interaction.request.headers.delete_if do |key, _value|
      %w[authorization cookie].any? { |sensitive| key.casecmp(sensitive).zero? }
    end
    interaction.response.headers.delete_if { |key, _value| key.casecmp('set-cookie').zero? }
    if SpeedyVcrSanitizer::MUTATION_CASSETTES.include?(cassette.name)
      SpeedyVcrSanitizer.sanitize_mutation!(interaction)
    else
      SpeedyVcrSanitizer.sanitize_response!(interaction)
    end
  end
end

if replay_only
  # VCR otherwise overrides WebMock's policy while its adapter is enabled.
  WebMock.singleton_class.prepend(Module.new do
    def net_connect_allowed?(*_arguments)
      false
    end
  end)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.filter_run_excluding live: true unless ENV['SPEEDY_LIVE_TESTS'] == '1'
  config.filter_run_excluding mutation: true unless ENV['SPEEDY_MUTATING_LIVE_TESTS'] == '1'
  config.filter_run_excluding replay: true unless ENV['SPEEDY_VCR_REPLAY'] == '1'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
