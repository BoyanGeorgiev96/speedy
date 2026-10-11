# frozen_string_literal: true

RSpec.describe 'Speedy existing-shipment read contracts', :live do
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

  it 'loads shipment information', cassette: 'speedy_api/shipment_information' do
    require_values!('SPEEDY_CONTRACT_SHIPMENT_IDS', shipment_ids)
    shipments = Speedy::Client.instance.shipment_info(*shipment_ids)

    expect(shipments).to all(be_a(Speedy::Models::Shipments::Shipment))
  end

  it 'loads secondary shipments', cassette: 'speedy_api/secondary_shipments' do
    require_values!('SPEEDY_CONTRACT_SHIPMENT_IDS', shipment_ids)
    shipments = Speedy::Client.instance.secondary_shipments(shipment_id: shipment_ids.first)

    expect(shipments).to all(be_a(Speedy::Models::Shipments::SecondaryShipment))
  end

  it 'finds parcels by reference', cassette: 'speedy_api/parcels_by_reference' do
    reference = ENV.fetch('SPEEDY_CONTRACT_REFERENCE', '')
    skip 'Set SPEEDY_CONTRACT_REFERENCE to record this read-only contract' if reference.empty?

    expect(Speedy::Client.instance.find_parcels_by_reference(ref: reference, search_in_ref: 1))
      .to all(be_a(String))
  end

  it 'tracks existing parcels', cassette: 'speedy_api/tracking' do
    require_values!('SPEEDY_CONTRACT_PARCEL_IDS', parcel_ids)
    parcels = Speedy::Client.instance.track_shipments(
      parcels: parcel_ids.map { |id| { id: id } },
      last_operation_only: false
    )

    expect(parcels).to all(be_a(Speedy::Models::Tracking::TrackedParcel))
  end

  it 'loads barcode information', cassette: 'speedy_api/barcode_information' do
    require_values!('SPEEDY_CONTRACT_PARCEL_IDS', parcel_ids)
    barcode = Speedy::Client.instance.barcode_information(parcel: { id: parcel_ids.first })

    expect(barcode).to be_a(Speedy::Models::Shipments::BarcodeInformation)
  end

  it 'loads label metadata without printing', cassette: 'speedy_api/label_info' do
    require_values!('SPEEDY_CONTRACT_PARCEL_IDS', parcel_ids)
    info = Speedy::Client.instance.label_info(parcel: { id: parcel_ids.first })

    expect(info).to be_a(Speedy::Models::Print::LabelInfoResponse)
  end

  def shipment_ids
    configured_list('SPEEDY_CONTRACT_SHIPMENT_IDS')
  end

  def parcel_ids
    configured_list('SPEEDY_CONTRACT_PARCEL_IDS')
  end

  def configured_list(key)
    ENV.fetch(key, '').split(',').map(&:strip).reject(&:empty?)
  end

  def require_values!(key, values)
    skip "Set #{key} to record this read-only contract" if values.empty?
  end
end
