# frozen_string_literal: true

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
end
