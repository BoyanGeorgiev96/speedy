# frozen_string_literal: true

RSpec.describe 'Speedy location nomenclature contracts', :live do
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

  it 'finds streets in Sofia', cassette: 'speedy_api/streets' do
    expect(Speedy::Client.instance.find_streets(site_id: 68_134, name: 'Витоша'))
      .to all(be_a(Speedy::Models::Location::Street))
  end

  it 'finds complexes in Sofia', cassette: 'speedy_api/complexes' do
    expect(Speedy::Client.instance.find_complexes(site_id: 68_134))
      .to all(be_a(Speedy::Models::Location::Complex))
  end

  it 'finds blocks in Sofia', cassette: 'speedy_api/blocks' do
    expect(Speedy::Client.instance.find_blocks(site_id: 68_134))
      .to all(be_a(Speedy::Models::Location::Block))
  end

  it 'finds points of interest in Sofia', cassette: 'speedy_api/points_of_interest' do
    expect(Speedy::Client.instance.find_points_of_interest(site_id: 68_134))
      .to all(be_a(Speedy::Models::Location::PointOfInterest))
  end

  it 'finds states for Bulgaria', cassette: 'speedy_api/states' do
    expect(Speedy::Client.instance.find_states(country_id: 100))
      .to all(be_a(Speedy::Models::Location::State))
  end

  it 'loads an office by configured id', cassette: 'speedy_api/office_detail' do
    office_id = configured_integer('SPEEDY_CONTRACT_OFFICE_ID')
    skip 'Set SPEEDY_CONTRACT_OFFICE_ID to record this read-only contract' unless office_id

    expect(Speedy::Client.instance.get_office(office_id))
      .to be_a(Speedy::Models::Location::GetOfficeResponse)
  end

  it 'loads a street by configured id', cassette: 'speedy_api/street_detail' do
    street_id = configured_integer('SPEEDY_CONTRACT_STREET_ID')
    skip 'Set SPEEDY_CONTRACT_STREET_ID to record this read-only contract' unless street_id

    expect(Speedy::Client.instance.get_street(street_id)).to be_a(Speedy::Models::Location::Street)
  end

  it 'loads a complex by configured id', cassette: 'speedy_api/complex_detail' do
    complex_id = configured_integer('SPEEDY_CONTRACT_COMPLEX_ID')
    skip 'Set SPEEDY_CONTRACT_COMPLEX_ID to record this read-only contract' unless complex_id

    expect(Speedy::Client.instance.get_complex(complex_id)).to be_a(Speedy::Models::Location::Complex)
  end

  it 'loads a point of interest by configured id', cassette: 'speedy_api/poi_detail' do
    poi_id = configured_integer('SPEEDY_CONTRACT_POI_ID')
    skip 'Set SPEEDY_CONTRACT_POI_ID to record this read-only contract' unless poi_id

    expect(Speedy::Client.instance.get_point_of_interest(poi_id))
      .to be_a(Speedy::Models::Location::PointOfInterest)
  end

  it 'loads a state by configured id', cassette: 'speedy_api/state_detail' do
    state_id = ENV.fetch('SPEEDY_CONTRACT_STATE_ID', '')
    skip 'Set SPEEDY_CONTRACT_STATE_ID to record this read-only contract' if state_id.empty?

    expect(Speedy::Client.instance.get_state(state_id)).to be_a(Speedy::Models::Location::State)
  end

  {
    all_countries: [Speedy::Models::Location::Country, {}],
    all_sites: [Speedy::Models::Location::Site, { country_id: 100 }],
    all_streets: [Speedy::Models::Location::Street, { country_id: 100 }],
    all_complexes: [Speedy::Models::Location::Complex, { country_id: 100 }],
    all_blocks: [Speedy::Models::Location::Block, { country_id: 100 }],
    all_points_of_interest: [Speedy::Models::Location::PointOfInterest, { country_id: 100 }],
    all_postcodes: [Speedy::Models::Location::Postcode, { country_id: 100 }],
    all_states: [Speedy::Models::Location::State, { country_id: 100 }]
  }.each do |method, (model, arguments)|
    it "loads #{method} bulk CSV nomenclature",
       cassette: "speedy_api/#{method}" do
      require_bulk_nomenclatures!

      expect(Speedy::Client.instance.public_send(method, **arguments)).to all(be_a(model))
    end
  end

  def configured_integer(key)
    Integer(ENV.fetch(key, nil), 10, exception: false)
  end

  def require_bulk_nomenclatures!
    return if ENV.fetch('SPEEDY_CONTRACT_BULK_NOMENCLATURES', '0') == '1'

    skip 'Set SPEEDY_CONTRACT_BULK_NOMENCLATURES=1 when the account has bulk-data permission'
  end
end
