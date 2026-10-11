# frozen_string_literal: true

require 'date'

module Speedy
  module ResourceAttributes
    TYPE_CASTERS = {
      integer: ->(value) { blank?(value) ? nil : value.to_i },
      string: ->(value) { value&.to_s },
      boolean: lambda do |value|
        next nil if blank?(value)
        next false if value == false || %w[false 0 no off].include?(value.to_s.downcase)

        true
      end,
      float: ->(value) { blank?(value) ? nil : value.to_f }
    }.freeze

    def self.blank?(value)
      value.nil? || (value.is_a?(String) && value.strip.empty?)
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def fields
        @fields ||= {}
      end

      def field(name, opts = {})
        fields[name] = opts

        define_method(name) do
          cast_attribute(@attributes[name], opts[:type], opts[:of])
        end

        define_method("#{name}=") do |value|
          @attributes[name] = cast_attribute(value, opts[:type], opts[:of])
        end
      end
    end

    private

    def cast_attribute(value, type, collection_type = nil)
      return cast_primitive(value, type) if TYPE_CASTERS.key?(type)
      return cast_date(value) if type == :date
      return cast_array(value, collection_type) if type == :array
      return cast_hash(value, collection_type) if type == :hash

      return cast_model(value, type) if type.is_a?(Class)

      value
    end

    def cast_primitive(value, type)
      TYPE_CASTERS.fetch(type).call(value)
    end

    def cast_model(value, type)
      value.nil? || value.is_a?(type) ? value : type.new(value)
    end

    def cast_date(value)
      return value if value.nil? || value.is_a?(Date)

      Date.parse(value.to_s)
    rescue StandardError
      value
    end

    def cast_array(value, collection_type)
      values = Array(value)
      return values unless collection_type.is_a?(Class)

      values.map { |item| item.is_a?(collection_type) ? item : collection_type.new(item) }
    end

    def cast_hash(value, value_type)
      return value unless value.is_a?(Hash) && value_type.is_a?(Class)

      value.transform_values { |item| item.is_a?(value_type) ? item : value_type.new(item) }
    end
  end
end
