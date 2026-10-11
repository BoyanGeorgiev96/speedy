# frozen_string_literal: true

module SpeedyVcrPrintSanitizer
  # Opaque documents are replaced entirely; never attempt partial PDF redaction.
  def sanitize_print_response!(interaction)
    interaction.response.body = redacted_print_body(interaction.response.body.to_s)
    return unless interaction.response.respond_to?(:headers)

    interaction.response.headers&.delete_if { |key, _value| key.match?(/\A(?:content-disposition|content-length)\z/i) }
  end

  def redacted_print_body(body)
    return SpeedyVcrSanitizer::REDACTED_PDF if body.b.start_with?('%PDF-'.b)

    parsed = parse_json(body.dup.force_encoding(Encoding::UTF_8))
    return '<REDACTED_DOCUMENT>' unless parsed.is_a?(Hash)

    redact_print_data!(parsed)
    JSON.pretty_generate(sanitize(parsed))
  rescue JSON::ParserError, ArgumentError
    '<REDACTED_DOCUMENT>'
  end

  def redact_print_data!(parsed)
    return if parsed['data'].nil?

    data = parsed['data']
    pdf = data.is_a?(String) && data.unpack1('m0').start_with?('%PDF-')
    parsed['data'] = pdf ? [SpeedyVcrSanitizer::REDACTED_PDF].pack('m0') : '<REDACTED_DOCUMENT>'
  end
end
