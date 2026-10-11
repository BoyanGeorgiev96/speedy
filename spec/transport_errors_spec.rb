# frozen_string_literal: true

RSpec.describe 'Speedy transport errors' do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) do
    Speedy::Client.new.tap do |value|
      value.username = 'offline-user'
      value.password = 'offline-password'
      value.adapter = [:test, stubs]
      value.setup_connection!
    end
  end
  let(:resource) do
    Class.new(Speedy::ServiceResource) { resource_path 'transport-test' }.new(client: client)
  end

  {
    Faraday::TimeoutError => [Speedy::TimeoutError, 'Speedy API request timed out.'],
    Faraday::ConnectionFailed => [Speedy::ConnectionError, 'Could not connect to the Speedy API.'],
    Faraday::SSLError => [Speedy::SSLError, 'Speedy API TLS connection failed.']
  }.each do |original_class, (wrapper_class, message)|
    %i[get post delete].each do |verb|
      it "wraps #{original_class} from #{verb} without leaking its message or retrying" do
        original = original_class.new('credential=private-password customer=Private Name')
        attempts = 0
        stubs.public_send(verb, '/v1/transport-test') do
          attempts += 1
          raise original
        end

        expect { resource.send(verb) }.to raise_error(wrapper_class) { |error| assert_transport(error, original, message) }
        expect(attempts).to eq(1)
      end
    end
  end

  [Faraday::ParsingError, Faraday::InitializationError, Faraday::Error, ArgumentError, NoMethodError].each do |error_class|
    it "does not disguise #{error_class} as a transport error" do
      original = error_class.new('Unexpected error')
      stubs.post('/v1/transport-test') { raise original }
      expect { resource.send(:post) }.to(raise_error { |error| expect(error).to equal(original) })
    end
  end

  it 'preserves HTTP status handling rather than inventing a transport failure' do
    stubs.post('/v1/transport-test') { [503, {}, ''] }
    expect { resource.send(:post) }.to raise_error(Speedy::Error) do |error|
      expect(error).not_to be_a(Speedy::TransportError)
      expect(error.status).to eq(503)
    end
  end

  it 'does not wrap a failure processing an existing response' do
    original = Faraday::ConnectionFailed.new('Unrelated response handler failure')
    stubs.post('/v1/transport-test') { [200, {}, ''] }
    allow(resource).to receive(:response_for).and_raise(original)
    expect { resource.send(:post) }.to(raise_error { |error| expect(error).to equal(original) })
  end

  it 'does not retry a shipment creation after a timeout' do
    original = Faraday::TimeoutError.new('Private backend details')
    attempts = 0
    stubs.post('/v1/shipment') do
      attempts += 1
      raise original
    end
    expect do
      client.create_shipment(recipient: {}, service: {}, content: {}, payment: {})
    end.to raise_error(Speedy::TimeoutError) { |error| expect(error.cause).to equal(original) }
    expect(attempts).to eq(1)
  end

  def assert_transport(error, original, message)
    expect(error).to be_a(Speedy::TransportError).and be_a(Speedy::Error)
    expect(error).to have_attributes(message: message, status: nil, error: nil)
    expect(error.cause).to equal(original)
  end
end
