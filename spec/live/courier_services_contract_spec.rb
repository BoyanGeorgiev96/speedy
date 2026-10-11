# frozen_string_literal: true

RSpec.describe 'Speedy courier services API contract', :live do
  around do |example|
    VCR.use_cassette('speedy_api/courier_services') { example.run }
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

  it 'loads typed courier services available to the account' do
    services = Speedy::Client.instance.courier_services

    expect(services).not_to be_empty
    expect(services).to all(be_a(Speedy::Models::Services::CourierService))
    expect(services.map(&:id)).to all(be_a(Integer))
    expect(services.map(&:name)).to all(be_a(String))
  end
end
