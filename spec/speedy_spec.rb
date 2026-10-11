# frozen_string_literal: true

require 'stringio'

RSpec.describe Speedy do
  it 'has a version number' do
    expect(Speedy::VERSION).not_to be nil
  end

  it 'configures a client' do
    stubs = Faraday::Adapter::Test::Stubs.new

    client = Speedy::Client.new
    client.username = 'user'
    client.password = 'pass'
    client.adapter = [:test, stubs]
    client.setup_connection!

    expect(client.connection).to be_a(Faraday::Connection)
  end

  it 'configures bounded network timeouts' do
    client = Speedy::Client.new
    client.username = 'user'
    client.password = 'pass'
    client.open_timeout = 4
    client.read_timeout = 5
    client.write_timeout = 6
    client.setup_connection!

    expect(client.connection.options).to have_attributes(
      open_timeout: 4,
      timeout: 5,
      write_timeout: 6
    )
  end

  it 'exposes standard collection emptiness checks' do
    collection = Speedy::Models::Location::Country.collection('countries' => [])

    expect(collection).to be_empty
  end

  describe 'debug logging' do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:output) { StringIO.new }
    let(:client) do
      Speedy::Client.new.tap do |configured_client|
        configured_client.username = 'secret-user'
        configured_client.password = 'secret-password'
        configured_client.client_system_id = 12_345
        configured_client.adapter = [:test, stubs]
        configured_client.debug = true
        configured_client.debug_logger = Logger.new(output)
      end
    end

    it 'does not log request or response bodies by default' do
      stubs.post('/v1/debug') { [200, { 'Content-Type' => 'application/json' }, { token: 'response-secret' }] }
      client.setup_connection!

      client.connection.post('debug', { note: 'request-secret' })

      expect(output.string).not_to include('request-secret', 'response-secret')
    end

    it 'redacts configured credentials when body logging is explicitly enabled' do
      stubs.post('/v1/debug') { [200, { 'Content-Type' => 'application/json' }, { owner: 'secret-user' }] }
      client.debug_bodies = true
      client.setup_connection!

      client.connection.post('debug', client.credentials)

      expect(output.string).to include('[FILTERED]')
      expect(output.string).not_to include('secret-user', 'secret-password', '12345')
    end
  end

  it 'exposes website integration shortcuts' do
    client = Speedy::Client.new

    expect(client).to respond_to(:calculate_delivery_fee)
    expect(client).to respond_to(:create_shipment)
    expect(client).to respond_to(:print_labels)
    expect(client).to respond_to(:find_sites)
    expect(client).to respond_to(:all_states)
    expect(client).to respond_to(:find_offices)
    expect(client).to respond_to(:validate_address)
  end

  it 'supports the speedy-bg Bundler autorequire shim' do
    expect { require 'speedy-bg' }.not_to raise_error
  end
end
