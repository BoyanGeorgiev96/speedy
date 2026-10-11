# frozen_string_literal: true

RSpec.describe 'Speedy read-only catalog contracts', :live do
  around do |example|
    VCR.use_cassette(example.metadata.fetch(:cassette)) { example.run }
  end

  before do
    configure_speedy_contract_client
  end

  it 'loads one country by id', cassette: 'speedy_api/country_detail' do
    country = Speedy::Client.instance.get_country(100)

    expect(country).to be_a(Speedy::Models::Location::Country)
    expect(country.iso_alpha2).to eq('BG')
  end

  it 'loads Sofia by id', cassette: 'speedy_api/site_detail' do
    site = Speedy::Client.instance.get_site(68_134)

    expect(site).to be_a(Speedy::Models::Location::GetSiteResponse)
  end

  it 'loads nearest offices for a synthetic address', cassette: 'speedy_api/nearest_offices' do
    offices = Speedy::Client.instance.nearest_offices(
      address: { country_id: 100, site_id: 68_134, address_line1: 'бул. Витоша 1' },
      limit: 3
    )

    expect(offices).not_to be_empty
    expect(offices).to all(be_a(Speedy::Models::Location::OfficeResult))
  end

  it 'loads pickup terms without requesting a pickup', cassette: 'speedy_api/pickup_terms' do
    terms = Speedy::Client.instance.pickup_terms(service_id: 505)

    expect(terms).to be_a(Speedy::Models::Pickup::TermsResponse)
    expect(terms).not_to be_error
  end

  it 'validates a synthetic phone number', cassette: 'speedy_api/phone_validation' do
    result = Speedy::Client.instance.validate_phone(number: '+359888000000')

    expect(result).to be_a(Speedy::Models::Validation::ValidationResponse)
    expect(result).to be_valid
  end

  it 'validates a synthetic address', cassette: 'speedy_api/address_validation' do
    result = Speedy::Client.instance.validate_address(
      country_id: 100,
      site_id: 68_134,
      address_line1: 'бул. Витоша 1'
    )

    expect(result).to be_a(Speedy::Models::Validation::ValidationResponse)
    expect(result).to be_valid
  end

  def configure_speedy_contract_client
    Speedy::Client.configure do |config|
      config.username = ENV.fetch('SPEEDY_USERNAME')
      config.password = ENV.fetch('SPEEDY_PASSWORD')
      config.client_system_id = Integer(ENV.fetch('SPEEDY_CLIENT_SYSTEM_ID', nil), 10, exception: false)
      config.base_url = ENV.fetch('SPEEDY_BASE_URL', 'https://api.speedy.bg/v1/')
    end
  end
end
