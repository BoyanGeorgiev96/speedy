# frozen_string_literal: true

require 'date'

module Speedy
  module ResourceAttributes
    TYPE_CASTERS = {
      integer: ->(value) { value&.to_i },
      string: ->(value) { value&.to_s },
      boolean: ->(value) { value != false && !value.nil? },
      float: ->(value) { value&.to_f }
    }.freeze

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
      return TYPE_CASTERS.fetch(type).call(value) if TYPE_CASTERS.key?(type)
      return cast_date(value) if type == :date
      return cast_array(value, collection_type) if type == :array

      if type.is_a?(Class)
        value.nil? || value.is_a?(type) ? value : type.new(value)
      else
        value
      end
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
  end
end
