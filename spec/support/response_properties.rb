# frozen_string_literal: true

# Deliberately independent of the client's key conversion and casting helpers.
module ResponseProperties
  # These API structures are dictionaries; their values remain typed objects.
  DICTIONARY_PATH = /\.(?:details|detailsLocal|externalCarrierParcelNumbersDetails)\z/

  def response_property_name(key)
    chars = key.to_s.chars
    chars.each_with_index.map do |char, index|
      boundary = index.positive? && char.match?(/[A-Z]/) &&
                 (chars[index - 1].match?(/[a-z0-9]/) || chars[index + 1]&.match?(/[a-z]/))
      "#{'_' if boundary}#{char.downcase}"
    end.join
  end

  def expect_response_properties(actual, raw, path: '$', conversions: {})
    return expect(actual).to eq(conversions.fetch(path).call(raw)), path if conversions.key?(path)

    case raw
    when Hash then expect_response_object(actual, raw, path, conversions)
    when Array then expect_response_array(actual, raw, path, conversions)
    else expect(actual).to eq(raw), path
    end
  end

  def expect_response_object(actual, raw, path, conversions)
    expect(actual).to be_a(path.match?(DICTIONARY_PATH) ? Hash : Speedy::Model), path
    raw.each do |key, value|
      name = response_property_name(key)
      child_path = "#{path}.#{key}"
      child = response_property(actual, name, child_path)
      expect_response_properties(child, value, path: child_path, conversions: conversions)
    end
  end

  def response_property(actual, name, path)
    if actual.is_a?(Hash)
      expect(actual).to have_key(name), path
      actual.fetch(name)
    else
      expect(actual).to respond_to(name), path
      actual.public_send(name)
    end
  end

  def expect_response_array(actual, raw, path, conversions)
    values = actual.is_a?(Speedy::Collection) ? actual.to_a : actual
    expect(values).to be_a(Array), path
    expect(values.size).to eq(raw.size), path
    raw.each_with_index do |value, index|
      expect_response_properties(values[index], value, path: "#{path}[#{index}]", conversions: conversions)
    end
  end
end
