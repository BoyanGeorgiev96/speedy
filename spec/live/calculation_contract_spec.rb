# frozen_string_literal: true

RSpec.describe 'Speedy non-mutating shipment preparation contracts', :live do
  around do |example|
    VCR.use_cassette(example.metadata.fetch(:cassette)) { example.run }
  end

  before do
    Speedy::Client.configure do |config|
      config.username = ENV.fetch('SPEEDY_USERNAME')
      config.password = ENV.fetch('SPEEDY_PASSWORD')
      config.client_system_id = Integer(ENV.fetch('SPEEDY_CLIENT_SYSTEM_ID', nil), 10, exception: false)
      config.base_url = ENV.fetch('SPEEDY_BASE_URL', 'https://api.speedy.bg/v1/')
    end
  end

  it 'calculates delivery without creating a shipment', cassette: 'speedy_api/calculation' do
    require_preparation_fixtures!
    calculations = Speedy::Client.instance.calculate_delivery_fee(**shipment_payload)

    expect(calculations).not_to be_error
    expect(calculations).not_to be_empty
    expect(calculations.first).to be_a(Speedy::Models::Calculation::CalculationResult)
    expect(calculations).to all(satisfy { |calculation| !calculation.error? })
  end

  it 'validates a shipment without creating it', cassette: 'speedy_api/shipment_validation' do
    require_preparation_fixtures!
    result = Speedy::Client.instance.validate_shipment(**shipment_payload(service_ids: false))

    expect(result).to be_a(Speedy::Models::Validation::ValidationResponse)
    expect(result).to be_valid
  end

  it 'loads destination services', cassette: 'speedy_api/destination_services' do
    require_preparation_fixtures!
    services = Speedy::Client.instance.destination_services(
      sender: { client_id: sender_client_id },
      recipient: shipment_recipient
    )

    expect(services).not_to be_empty
    expect(services).to all(be_a(Speedy::Models::Services::ExtendedCourierService))
  end

  def require_preparation_fixtures!
    skip 'Set SPEEDY_SENDER_CLIENT_ID and SPEEDY_CONTRACT_OFFICE_ID to record this contract' unless
      sender_client_id && office_id
  end

  def sender_client_id
    Integer(ENV.fetch('SPEEDY_SENDER_CLIENT_ID', nil), 10, exception: false)
  end

  def office_id
    Integer(ENV.fetch('SPEEDY_CONTRACT_OFFICE_ID', nil), 10, exception: false)
  end

  def shipment_payload(service_ids: true)
    {
      sender: { client_id: sender_client_id },
      recipient: shipment_recipient,
      service: (service_ids ? { service_ids: [505] } : { service_id: 505 }).merge(auto_adjust_pickup_date: true),
      content: { parcels_count: 1, total_weight: 1.0, contents: 'VCR fixture' },
      payment: { courier_service_payer: 'SENDER' }
    }
  end

  def shipment_recipient
    { pickup_office_id: office_id, private_person: true, client_name: 'VCR Receiver',
      contact_name: 'VCR Receiver', phone1: { number: '+359888000001' } }
  end
end
