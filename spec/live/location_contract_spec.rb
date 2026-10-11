# frozen_string_literal: true

RSpec.describe 'Speedy location API contract', :live do
  around do |example|
    VCR.use_cassette(example.metadata.fetch(:cassette)) { example.run }
  end

  before do
    Speedy::Client.configure do |config|
      config.username = ENV.fetch('SPEEDY_USERNAME')
      config.password = ENV.fetch('SPEEDY_PASSWORD')
      client_system_id = ENV.fetch('SPEEDY_CLIENT_SYSTEM_ID', nil)
      config.client_system_id = Integer(client_system_id, 10, exception: false)
      config.base_url = ENV.fetch('SPEEDY_BASE_URL', 'https://api.speedy.bg/v1/')
    end
  end

  it 'loads typed sites for Sofia', cassette: 'speedy_api/sites' do
    sites = Speedy::Client.instance.find_sites(country_id: 100, name: 'София', post_code: '1000')

    expect(sites).not_to be_empty
    expect(sites).to all(be_a(Speedy::Models::Location::Site))
    expect(sites.map(&:country_id)).to all(eq(100))
  end

  it 'loads typed offices for Sofia', cassette: 'speedy_api/offices' do
    offices = Speedy::Client.instance.find_offices(country_id: 100, site_name: 'София', limit: 3)

    expect(offices).not_to be_empty
    expect(offices).to all(be_a(Speedy::Models::Location::Office))
    expect(offices.map(&:id)).to all(be_a(Integer))
  end
end
