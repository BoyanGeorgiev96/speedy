# frozen_string_literal: true

RSpec.describe 'Speedy label metadata request normalization' do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) do
    Speedy::Client.new.tap do |value|
      value.username = 'offline-user'
      value.password = 'offline-password'
      value.adapter = [:test, stubs]
      value.setup_connection!
    end
  end

  [
    [{ parcel: { id: 'parcel-1' } }, [{ 'id' => 'parcel-1' }]],
    [{ parcel: [{ id: 'parcel-1' }, { id: 'parcel-2' }] }, [{ 'id' => 'parcel-1' }, { 'id' => 'parcel-2' }]],
    [{ parcel: { id: 'ignored' }, parcels: [{ id: 'parcel-2' }] }, [{ 'id' => 'parcel-2' }]],
    [{ parcel: { id: 'ignored' }, parcels: [] }, []],
    [{}, []]
  ].each_with_index do |(arguments, expected), index|
    it "preserves parcel references and explicit array precedence (case #{index + 1})" do
      stubs.post('/v1/print/labelInfo') do |env|
        expect(JSON.parse(env.body).fetch('parcels')).to eq(expected)
        [200, { 'Content-Type' => 'application/json' }, JSON.generate(printLabelsInfo: [])]
      end

      expect(client.label_info(**arguments)).to be_a(Speedy::Models::Print::LabelInfoResponse)
      stubs.verify_stubbed_calls
    end
  end
end
