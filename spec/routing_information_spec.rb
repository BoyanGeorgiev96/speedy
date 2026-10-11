# frozen_string_literal: true

RSpec.describe Speedy::Models::Location::RoutingInformation do
  it 'casts documented scalar fields and the nested tour' do
    routing = described_class.new(officeId: '9', hubId: '10', priority: '0',
                                  tour: { number: '7', officeId: '8', ramp: 'R1', cell: 'C2' })
    expect(routing.office_id).to eq(9)
    expect(routing.hub_id).to eq(10)
    expect(routing.priority).to eq(0)
    expect(routing.tour).to be_a(Speedy::Models::Location::Tour)
    expect(routing.tour.number).to eq(7)
    expect(routing.tour.office_id).to eq(8)
    expect(routing.tour.ramp).to eq('R1')
    expect(routing.tour.cell).to eq('C2')
  end

  it 'preserves absent and explicitly null optional routing fields' do
    [Speedy::Models::Location::Office, Speedy::Models::Location::OfficeResult].each do |model|
      expect(model.new.routing_information).to be_nil
      expect(model.new(routingInformation: nil).routing_information).to be_nil
      routing = model.new(routingInformation: { tour: nil }).routing_information
      expect(routing).to be_a(described_class)
      expect(routing.tour).to be_nil
      expect(routing.office_id).to be_nil
    end
  end

  it 'preserves already typed routing and tour instances' do
    tour = Speedy::Models::Location::Tour.new(number: 7)
    routing = described_class.new(tour: tour)
    office = Speedy::Models::Location::Office.new(routing_information: routing)
    expect(office.routing_information).to equal(routing)
    expect(routing.tour).to equal(tour)
  end

  it 'serializes routing back to the documented camelCase response shape' do
    raw = { 'tour' => { 'number' => 7, 'officeId' => 8, 'ramp' => 'R1', 'cell' => 'C2' },
            'officeId' => 9, 'hubId' => 10, 'priority' => 0 }
    expect(JSON.parse(described_class.new(raw).to_json)).to eq(raw)
  end
end
