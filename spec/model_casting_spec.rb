# frozen_string_literal: true

RSpec.describe 'Speedy schema-backed model casting' do
  it 'preserves blank CSV values and casts textual booleans correctly' do
    model_class = Class.new(Speedy::Model) do
      field :count, type: :integer
      field :amount, type: :float
      field :enabled, type: :boolean
    end

    expect(model_class.new(count: '', amount: ' ', enabled: '').to_h).to eq(
      count: nil, amount: nil, enabled: nil
    )
    expect(model_class.new(enabled: 'false').enabled).to be(false)
    expect(model_class.new(enabled: '0').enabled).to be(false)
    expect(model_class.new(enabled: 'true').enabled).to be(true)
  end

  it 'uses response-specific shipment parties, content, and payment models' do
    shipment = Speedy::Models::Shipments::Shipment.new(
      sender: { clientId: '10', phones: [{ number: '111' }] },
      recipient: { clientId: '20', pickupOfficeId: '30' },
      content: {
        declaredWeight: '1.5',
        parcels: [{ id: 'parcel-1', declaredSize: { width: '10' } }]
      },
      payment: {
        courierServicePayer: 'SENDER',
        discountCardId: { contractId: '40' },
        codPayment: { totalPayedOutAmount: '25.50' }
      }
    )

    expect(shipment.sender).to be_a(Speedy::Models::Shipments::Sender)
    expect(shipment.sender.phones.first.number).to eq('111')
    expect(shipment.recipient).to be_a(Speedy::Models::Shipments::Recipient)
    expect(shipment.recipient.pickup_office_id).to eq(30)
    expect(shipment.content).to be_a(Speedy::Models::Shipments::Content)
    expect(shipment.content.parcels.first.declared_size.width).to eq(10)
    expect(shipment.payment).to be_a(Speedy::Models::Shipments::Payment)
    expect(shipment.payment.discount_card_id.contract_id).to eq(40)
    expect(shipment.payment.cod_payment.total_payed_out_amount).to eq(25.5)
  end

  it 'casts shipment request additional services and parcel details' do
    shipment = Speedy::Models::Shipments::ShipmentContent.new(
      parcels: [{
        size: { width: '10', height: '20', depth: '30' },
        goods: [{ description: 'Painting', quantity: '2', valuePerItem: '12.5' }],
        printAdditionalBarcode: { valueType: 'PROVIDED', value: 'ART-1' }
      }]
    )
    service = Speedy::Models::Shipments::ShipmentService.new(
      additionalServices: {
        cod: {
          amount: '42.5',
          payoutToThirdParty: 'false',
          fiscalReceiptItems: [{ description: 'Print', amountWithVat: '12.5' }]
        },
        returns: { rop: { pallets: [{ serviceId: '1', parcelsCount: '2' }] } }
      }
    )

    parcel = shipment.parcels.first
    expect(parcel.size).to have_attributes(width: 10, height: 20, depth: 30)
    expect(parcel.goods.first).to have_attributes(quantity: 2, value_per_item: 12.5)
    expect(parcel.print_additional_barcode.value).to eq('ART-1')
    expect(service.additional_services.cod.payout_to_third_party).to be(false)
    expect(service.additional_services.cod.fiscal_receipt_items.first.amount_with_vat).to eq(12.5)
    expect(service.additional_services.returns.rop.pallets.first.parcels_count).to eq(2)
  end

  it 'casts price detail maps, returns, and tracking additional information' do
    price = Speedy::Models::Shipments::ShipmentPrice.new(
      details: { courier: { amount: '10', vatPercent: '20' } },
      returnAmounts: { moneyTransfer: { amount: '5', payer: 'RECIPIENT' } }
    )
    operation = Speedy::Models::Tracking::TrackedParcelOperation.new(
      additionalInfo: {
        officeURL: 'https://example.test/office',
        recipient: { countryId: '100' },
        predict: { includedDelayInMinutes: '15', canceled: 'false' }
      }
    )

    expect(price.details.values.first).to have_attributes(amount: 10.0, vat_percent: 20.0)
    expect(price.return_amounts.money_transfer.amount).to eq(5.0)
    expect(operation.additional_info.office_url).to eq('https://example.test/office')
    expect(operation.additional_info.recipient.country_id).to eq(100)
    expect(operation.additional_info.predict).to have_attributes(
      included_delay_in_minutes: 15, canceled: false
    )
  end
end
