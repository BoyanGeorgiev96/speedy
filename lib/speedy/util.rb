# frozen_string_literal: true

module Speedy
  module Util
    module_function

    def pluralize(word)
      base = underscore(word.to_s.split('::').last)

      if base.end_with?('y') && !base.end_with?('ay', 'ey', 'iy', 'oy', 'uy')
        "#{base[0..-2]}ies"
      elsif base.end_with?('s', 'x', 'z', 'ch', 'sh')
        "#{base}es"
      else
        "#{base}s"
      end
    end

    def camel_case(str)
      str.gsub(/_([a-z])/) { ::Regexp.last_match(1).upcase }
    end

    def underscore(str)
      str
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .downcase
    end

    def underscore_keys(hash)
      return hash if primitive_value?(hash)

      hash.each_with_object({}) do |(key, value), result|
        result[underscore(key.to_s)] = case value
                                       when Hash
                                         underscore_keys(value)
                                       when Array
                                         value.map { |v| underscore_keys(v) }
                                       else
                                         value
                                       end
      end
    end

    def camelize_keys(hash)
      return hash if primitive_value?(hash)

      hash.each_with_object({}) do |(key, value), result|
        result[camel_case(key.to_s)] = case value
                                       when Hash
                                         camelize_keys(value)
                                       when Array
                                         value.map { |v| camelize_keys(v) }
                                       else
                                         value
                                       end
      end
    end

    def primitive_value?(value)
      PRIMITIVE_TYPES.any? { |type| value.is_a?(type) }
    end

    PRIMITIVE_TYPES = [String, Numeric, TrueClass, FalseClass, NilClass].freeze
    private_constant :PRIMITIVE_TYPES
  end
end
