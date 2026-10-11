# frozen_string_literal: true

module SpeedyRecordedContractAssertions
  def assert_recorded_result(result, model, selected, interaction)
    body = interaction.fetch('response').fetch('body').fetch('string')
    return expect(result).to eq(body) if model == String

    raw = SpeedyVcrSanitizer.parse_json(body)
    return assert_recorded_error(result, raw.fetch('error')) if raw['error']

    assert_recorded_properties(result, model, selected ? raw.fetch(selected) : raw)
  end

  def assert_recorded_error(result, raw)
    expect(result).to be_error
    expect_response_properties(result.error, raw)
  end

  def assert_recorded_properties(result, model, raw)
    assert_result_type(result, model, raw)
    expect_response_properties(result, raw, conversions: recorded_date_conversions(raw, model))
  end

  def assert_result_type(result, model, raw)
    if raw.is_a?(Array)
      expect(result).to be_a(Speedy::Collection)
      expect(result).to all(be_a(model))
    else
      expect(result).to be_a(model)
    end
  end

  def recorded_date_conversions(raw, model)
    return {} unless model == Speedy::Models::Payments::Payout

    raw.each_with_index.with_object({}) do |(row, index), result|
      prefix = "$[#{index}]"
      result["#{prefix}.date"] = ->(value) { Date.parse(value) } if row['date']
      payout_detail_conversions(row, prefix, result)
    end
  end

  def payout_detail_conversions(row, prefix, result)
    Array(row['details']).each_index do |detail|
      %w[pickupDate primaryShipmentPickupDate deliveryDate].each do |key|
        result["#{prefix}.details[#{detail}].#{key}"] = ->(value) { value.nil? ? nil : Date.parse(value) }
      end
    end
  end
end
