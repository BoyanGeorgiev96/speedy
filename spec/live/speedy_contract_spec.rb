# frozen_string_literal: true

RSpec.describe 'Speedy API contract', :live do
  around do |example|
    VCR.use_cassette('speedy_api/countries') { example.run }
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

  it 'loads typed country nomenclatures' do
    countries = Speedy::Client.instance.find_countries(iso_alpha2: 'BG')

    expect(countries).not_to be_empty
    expect(countries.first).to be_a(Speedy::Models::Location::Country)
    expect(countries.first.iso_alpha2).to eq('BG')
  end
end
