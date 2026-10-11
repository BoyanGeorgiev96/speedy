# frozen_string_literal: true

RSpec.describe 'Speedy expanded services' do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) do
    Speedy::Client.new.tap do |configured_client|
      configured_client.username = 'speedy-user'
      configured_client.password = 'speedy-pass'
      configured_client.client_system_id = 42
      configured_client.adapter = [:test, stubs]
      configured_client.setup_connection!
    end
  end

  it 'retrieves schema-backed shipment information' do
    stubs.post('https://api.speedy.bg/v1/shipment/info') do |env|
      expect(JSON.parse(env.body)).to include(
        'clientSystemId' => 42,
        'shipmentIds' => %w[700000001 700000002]
      )

      [
        200,
        { 'Content-Type' => 'application/json' },
        {
          shipments: [{
            id: '700000001',
            recipient: { clientName: 'Customer' },
            delivery: { consignee: 'Customer' },
            pendingShipment: false
          }]
        }.to_json
      ]
    end

    shipment = client.shipment_info('700000001', '700000002').first

    expect(shipment.id).to eq('700000001')
    expect(shipment.recipient.client_name).to eq('Customer')
    expect(shipment.delivery.consignee).to eq('Customer')
    expect(shipment.pending_shipment).to be(false)
  end

  it 'updates, cancels, finalizes, and adds parcels to shipments' do
    stubs.post('https://api.speedy.bg/v1/shipment/update/properties') do |env|
      expect(JSON.parse(env.body)).to include(
        'id' => '700000001',
        'properties' => { 'ref1' => 'ORDER-1' }
      )
      [200, { 'Content-Type' => 'application/json' }, { id: '700000001', parcels: [] }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/shipment/cancel') do |env|
      expect(JSON.parse(env.body)).to include('shipmentId' => '700000001', 'comment' => 'Duplicate')
      [200, { 'Content-Type' => 'application/json' }, {}.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/shipment/finalize') do |env|
      expect(JSON.parse(env.body)).to include('shipmentId' => '700000001')
      [200, { 'Content-Type' => 'application/json' }, { id: '700000001', parcels: [] }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/shipment/add_parcel') do |env|
      expect(JSON.parse(env.body)).to include(
        'shipmentId' => '700000001', 'parcel' => hash_including('weight' => 1.2)
      )
      [200, { 'Content-Type' => 'application/json' }, { parcel: { id: '700000001002', seqNo: 2 } }.to_json]
    end

    expect(client.update_shipment_properties(id: '700000001', ref1: 'ORDER-1').id).to eq('700000001')
    expect(client.cancel_shipment(id: '700000001', comment: 'Duplicate')).to be_success
    expect(client.finalize_shipment(id: '700000001').id).to eq('700000001')
    parcel = client.add_shipment_parcel(shipment_id: '700000001', parcel: { weight: 1.2 })
    expect(parcel).to have_attributes(id: '700000001002', seq_no: 2)
  end

  it 'tracks parcels and casts nested operations' do
    stubs.post('https://api.speedy.bg/v1/track') do |env|
      expect(JSON.parse(env.body)).to include(
        'parcels' => [{ 'id' => '700000001001' }],
        'lastOperationOnly' => true
      )
      [
        200,
        { 'Content-Type' => 'application/json' },
        { parcels: [{
          parcelId: '700000001001',
          trackPhase: 'DELIVERED',
          operations: [{ operationCode: 100, description: 'Delivered' }]
        }] }.to_json
      ]
    end

    parcel = client.track_shipments(
      parcels: [{ id: '700000001001' }], last_operation_only: true
    ).first

    expect(parcel.track_phase).to eq('DELIVERED')
    expect(parcel.operations.first).to have_attributes(operation_code: 100, description: 'Delivered')
  end

  it 'lists services globally and for a destination' do
    service_body = { services: [{ id: 505, name: 'Standard', requireParcelWeight: true }] }.to_json
    stubs.post('https://api.speedy.bg/v1/services') do |env|
      expect(JSON.parse(env.body)).to include('date' => 1_759_622_400_000)
      [200, { 'Content-Type' => 'application/json' }, service_body]
    end
    stubs.post('https://api.speedy.bg/v1/services/destination') do |env|
      expect(JSON.parse(env.body)).to include(
        'sender' => hash_including('clientId' => 1),
        'recipient' => hash_including('siteId' => 68_134)
      )
      [200, { 'Content-Type' => 'application/json' }, service_body]
    end

    expect(client.courier_services(date: 1_759_622_400_000).first.id).to eq(505)
    destination = client.destination_services(sender: { client_id: 1 }, recipient: { site_id: 68_134 })
    expect(destination.first.require_parcel_weight).to be(true)
  end

  it 'requests courier pickup using the schema payload' do
    stubs.post('https://api.speedy.bg/v1/pickup') do |env|
      expect(JSON.parse(env.body)).to include(
        'pickupDateTime' => '2026-10-06T10:00:00+03:00',
        'explicitShipmentIdList' => ['700000001']
      )
      [
        200,
        { 'Content-Type' => 'application/json' },
        { orders: [{ id: 77, shipmentIds: ['700000001'] }] }.to_json
      ]
    end

    order = client.request_pickup(
      pickup_date_time: '2026-10-06T10:00:00+03:00',
      explicit_shipment_id_list: ['700000001']
    ).first

    expect(order).to have_attributes(id: 77, shipment_ids: ['700000001'])
  end

  it 'finds countries and streets with typed responses' do
    stubs.post('https://api.speedy.bg/v1/location/country') do |env|
      expect(JSON.parse(env.body)).to include('isoAlpha2' => 'BG')
      [200, { 'Content-Type' => 'application/json' }, { countries: [{ id: 100, isoAlpha2: 'BG' }] }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/location/street') do |env|
      expect(JSON.parse(env.body)).to include('siteId' => 68_134, 'name' => 'Витоша')
      [200, { 'Content-Type' => 'application/json' }, { streets: [{ id: 1, name: 'Витоша' }] }.to_json]
    end

    expect(client.find_countries(iso_alpha2: 'BG').first.id).to eq(100)
    expect(client.find_streets(site_id: 68_134, name: 'Витоша').first.name).to eq('Витоша')
  end

  it 'validates phone numbers and postcodes' do
    stubs.post('https://api.speedy.bg/v1/validation/phone') do |env|
      expect(JSON.parse(env.body)).to include('number' => '+359888123456', 'ext' => '12')
      [200, { 'Content-Type' => 'application/json' }, { valid: true }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/validation/postcode') do |env|
      expect(JSON.parse(env.body)).to include('countryId' => 100, 'postCode' => '1000')
      [200, { 'Content-Type' => 'application/json' }, { valid: true }.to_json]
    end

    expect(client.validate_phone(number: '+359888123456', extension: '12')).to be_valid
    expect(client.validate_post_code(country_id: 100, post_code: '1000')).to be_valid
  end
end
