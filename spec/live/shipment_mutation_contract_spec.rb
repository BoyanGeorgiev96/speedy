# frozen_string_literal: true

RSpec.describe 'Speedy shipment mutation contract', :live, :mutation do
  around do |example|
    cassette = example.metadata.fetch(:cassette, 'speedy_api/shipment_create_cancel_and_verify')
    VCR.use_cassette(cassette) { example.run }
  end

  before do
    Speedy::Client.configure do |config|
      config.username = ENV.fetch('SPEEDY_USERNAME')
      config.password = ENV.fetch('SPEEDY_PASSWORD')
      config.client_system_id = Integer(ENV.fetch('SPEEDY_CLIENT_SYSTEM_ID', nil), 10, exception: false)
      config.base_url = ENV.fetch('SPEEDY_BASE_URL', 'https://api.speedy.bg/v1/')
    end
  end

  it 'cancels a synthetic shipment and reads its retained record and empty tracking history' do
    require_fixtures!
    shipment = cleanup = verification = nil
    shipment_id = nil

    begin
      shipment = Speedy::Client.instance.create_shipment(**shipment_payload)
      shipment_id = shipment.id unless shipment.error?
    ensure
      if shipment_id
        cleanup = Speedy::Client.instance.cancel_shipment(
          id: shipment_id,
          comment: 'Automated VCR contract cleanup'
        )
        verification = Speedy::Client.instance.shipment_info(shipment_id)
      end
    end

    expect(shipment).to be_a(Speedy::Models::Shipments::CreateShipmentResponse)
    expect(shipment).not_to be_error
    expect(shipment_id).not_to be_nil
    expect(cleanup).to be_success
    expect(verification).to contain_exactly(be_a(Speedy::Models::Shipments::Shipment))
    expect(verification.first.id).to eq(shipment_id)

    parcel_id = shipment.parcels.first.id
    expect(parcel_id).not_to be_nil
    tracking = Speedy::Client.instance.track_shipments(
      parcels: [{ id: parcel_id }],
      last_operation_only: false
    )

    expect(tracking).to contain_exactly(be_a(Speedy::Models::Tracking::TrackedParcel))
    expect(tracking.first).not_to be_error
    expect(tracking.first.parcel_id).to eq(parcel_id)
    # Cancellation before collection returned no tracking events in the demo recording.
    # The successful cancel response above confirms cleanup; empty history does not.
    expect(tracking.first.operations).to be_empty
  end

  it 'replaces an uncollected shipment and cancels it', cassette: 'speedy_api/shipment_update_and_cancel' do
    with_synthetic_shipment do |created|
      payload = shipment_payload.merge(content: shipment_content.merge(contents: 'Updated VCR fixture'))
      updated = Speedy::Client.instance.update_shipment(id: created.id, **payload)

      expect(updated).to be_a(Speedy::Models::Shipments::UpdateShipmentResponse)
      expect(updated).not_to be_error
      expect(updated.id).to eq(created.id)
      expect(shipment_record(created.id).content.contents).to eq('Updated VCR fixture')
    end
  end

  it 'updates an uncollected shipment property and cancels it',
     cassette: 'speedy_api/shipment_properties_and_cancel' do
    with_synthetic_shipment do |created|
      updated = Speedy::Client.instance.update_shipment_properties(id: created.id, contents: 'Property VCR fixture')

      expect(updated).to be_a(Speedy::Models::Shipments::UpdateShipmentResponse)
      expect(updated).not_to be_error
      expect(shipment_record(created.id).content.contents).to eq('Property VCR fixture')
    end
  end

  def with_synthetic_shipment
    require_fixtures!
    created = nil
    begin
      created = Speedy::Client.instance.create_shipment(**shipment_payload)
      expect(created).not_to be_error
      expect(created.id).not_to be_nil
      yield created
    ensure
      cancel_fixture!(created.id) if created&.id
    end
  end

  def cancel_fixture!(id)
    cleanup = Speedy::Client.instance.cancel_shipment(id: id, comment: 'Automated VCR contract cleanup')
    expect(cleanup).to be_success
  end

  def shipment_record(id)
    records = Speedy::Client.instance.shipment_info(id)
    expect(records).to contain_exactly(be_a(Speedy::Models::Shipments::Shipment))
    expect(records.first).not_to be_error
    expect(records.first.id).to eq(id)
    records.first
  end

  def require_fixtures!
    missing = []
    missing << 'SPEEDY_SENDER_CLIENT_ID' unless sender_client_id
    missing << 'SPEEDY_CONTRACT_OFFICE_ID' unless office_id
    return if missing.empty?

    skip "Set valid integer values for: #{missing.join(', ')}"
  end

  def sender_client_id
    Integer(ENV.fetch('SPEEDY_SENDER_CLIENT_ID', nil), 10, exception: false)
  end

  def office_id
    Integer(ENV.fetch('SPEEDY_CONTRACT_OFFICE_ID', nil), 10, exception: false)
  end

  def shipment_payload
    {
      sender: { client_id: sender_client_id },
      recipient: shipment_recipient,
      service: { service_id: 505, auto_adjust_pickup_date: true },
      content: shipment_content,
      payment: { courier_service_payer: 'SENDER' },
      ref1: 'speedy-bg-vcr-contract-fixture'
    }
  end

  def shipment_recipient
    {
      client_name: 'VCR Contract Recipient',
      phone1: { number: '+359888000099' },
      private_person: true,
      pickup_office_id: office_id
    }
  end

  def shipment_content
    {
      parcels_count: 1,
      total_weight: 0.1,
      contents: 'Automated VCR contract fixture',
      package: 'PACKAGE'
    }
  end
end
