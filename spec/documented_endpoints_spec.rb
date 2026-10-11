# frozen_string_literal: true

RSpec.describe 'Speedy documented endpoint coverage' do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) do
    Speedy::Client.new.tap do |configured_client|
      configured_client.username = 'speedy-user'
      configured_client.password = 'speedy-pass'
      configured_client.adapter = [:test, stubs]
      configured_client.setup_connection!
    end
  end

  it 'gets and finds the remaining location nomenclatures' do
    stubs.post('https://api.speedy.bg/v1/location/state/SOF') do
      [200, { 'Content-Type' => 'application/json' }, { state: { id: 'SOF', name: 'Sofia' } }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/location/state') do |env|
      expect(JSON.parse(env.body)).to include('countryId' => 100, 'name' => 'Sofia')
      [200, { 'Content-Type' => 'application/json' }, { states: [{ id: 'SOF', name: 'Sofia' }] }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/location/complex/10') do
      [200, { 'Content-Type' => 'application/json' }, { complex: { id: 10, name: 'Mladost' } }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/location/complex') do |env|
      expect(JSON.parse(env.body)).to include('siteId' => 68_134, 'type' => 'кв.')
      [200, { 'Content-Type' => 'application/json' }, { complexes: [{ id: 10, name: 'Mladost' }] }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/location/block') do |env|
      expect(JSON.parse(env.body)).to include('siteId' => 68_134, 'name' => '12')
      [200, { 'Content-Type' => 'application/json' }, { blocks: [{ siteId: 68_134, name: '12' }] }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/location/poi/20') do
      [200, { 'Content-Type' => 'application/json' }, { poi: { id: 20, name: 'NDK' } }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/location/poi') do |env|
      expect(JSON.parse(env.body)).to include('siteId' => 68_134, 'name' => 'NDK')
      [200, { 'Content-Type' => 'application/json' }, { pois: [{ id: 20, name: 'NDK' }] }.to_json]
    end

    expect(client.get_state('SOF').name).to eq('Sofia')
    expect(client.find_states(country_id: 100, name: 'Sofia').first.id).to eq('SOF')
    expect(client.get_complex(10).name).to eq('Mladost')
    expect(client.find_complexes(site_id: 68_134, type: 'кв.').first.id).to eq(10)
    expect(client.find_blocks(site_id: 68_134, name: '12').first.name).to eq('12')
    expect(client.get_point_of_interest(20).name).to eq('NDK')
    expect(client.find_points_of_interest(site_id: 68_134, name: 'NDK').first.id).to eq(20)
  end

  it 'parses complex and block bulk CSV responses' do
    stubs.post('https://api.speedy.bg/v1/location/complex/csv/100') do
      [200, { 'Content-Type' => 'text/csv' }, "10,68134,кв.,qtr.,Младост,Mladost,10\n"]
    end
    stubs.post('https://api.speedy.bg/v1/location/block/csv/100') do
      [200, { 'Content-Type' => 'text/csv' }, "68134,12,12\n"]
    end

    complex = client.all_complexes(country_id: 100).first
    block = client.all_blocks(country_id: 100).first

    expect(complex).to have_attributes(id: 10, site_id: 68_134, name_en: 'Mladost')
    expect(block).to have_attributes(site_id: 68_134, name: '12')
  end

  it 'exposes existing location lookups through the client facade' do
    stubs.post('https://api.speedy.bg/v1/location/country/100') do
      [200, { 'Content-Type' => 'application/json' }, { country: { id: 100, name: 'Bulgaria' } }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/location/site/68134') do
      [200, { 'Content-Type' => 'application/json' }, { site: { id: 68_134, name: 'Sofia' } }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/location/street/1') do
      [200, { 'Content-Type' => 'application/json' }, { street: { id: 1, name: 'Vitosha' } }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/location/office/2') do
      [200, { 'Content-Type' => 'application/json' }, { office: { id: 2, name: 'Center' } }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/location/office/nearest-offices') do |env|
      expect(JSON.parse(env.body)).to include('address' => hash_including('siteId' => 68_134))
      body = { offices: [{ id: 2, name: 'Center', distance: 350 }] }
      [200, { 'Content-Type' => 'application/json' }, body.to_json]
    end

    expect(client.get_country(100).name).to eq('Bulgaria')
    expect(client.get_site(68_134).site.name).to eq('Sofia')
    expect(client.get_street(1).name).to eq('Vitosha')
    expect(client.get_office(2).office.name).to eq('Center')
    expect(client.nearest_offices(address: { site_id: 68_134 }).first.distance).to eq(350)
  end

  it 'validates shipments and returns raw labels from the basic print endpoint' do
    stubs.post('https://api.speedy.bg/v1/validation/shipment') do |env|
      expect(JSON.parse(env.body)).to include(
        'service' => { 'serviceId' => 505 },
        'recipient' => { 'pickupOfficeId' => 123 }
      )
      [200, { 'Content-Type' => 'application/json' }, { valid: true }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/print') do |env|
      expect(JSON.parse(env.body)).to include('paperSize' => 'A6')
      [200, { 'Content-Type' => 'application/pdf' }, '%PDF-label']
    end

    validation = client.validate_shipment(
      service: { service_id: 505 }, content: { parcels_count: 1, total_weight: 1.0 },
      payment: { courier_service_payer: 'SENDER' }, recipient: { pickup_office_id: 123 }
    )

    expect(validation).to be_valid
    expect(client.print_labels_pdf(parcels: [{ parcel_id: { id: '1' } }], paper_size: 'A6')).to eq('%PDF-label')
  end

  it 'uses schema-specific models for destination services and nearest offices' do
    stubs.post('https://api.speedy.bg/v1/services/destination') do
      body = { services: [{ id: 505, name: 'Standard', deadline: '2026-10-07T18:00:00+03:00' }] }
      [200, { 'Content-Type' => 'application/json' }, body.to_json]
    end

    service = client.destination_services(sender: { client_id: 1 }, recipient: { site_id: 68_134 }).first

    expect(service).to be_a(Speedy::Models::Services::ExtendedCourierService)
    expect(service.deadline).to eq('2026-10-07T18:00:00+03:00')
  end
end
