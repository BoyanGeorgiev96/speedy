# frozen_string_literal: true

module Speedy
  class Model
    include Speedy::ResourceAttributes
    include Speedy::Util

    class << self
      def collection_key(value = nil)
        return @collection_key || Speedy::Util.pluralize(name).to_sym unless value

        @collection_key = value
      end

      def collection(source)
        Speedy::Collection.new(source, model: self, key: collection_key)
      end

      def build(source, key: nil)
        data = extract_source(source, key)
        new(data.is_a?(Hash) ? data : {})
      end

      private

      def extract_source(source, key)
        return source unless source.is_a?(Hash)
        return source unless key && (source.key?(key) || source.key?(key.to_s))

        source[key] || source[key.to_s]
      end
    end

    def initialize(attributes = {})
      @attributes = {}
      @error = Speedy::Models::Error.build_from(attributes) unless is_a?(Speedy::Models::Error)
      apply_attributes(attributes)
    end

    attr_reader :error

    def error?
      !error.nil?
    end

    def method_missing(method_name, *args, &)
      if @attributes.key?(method_name)
        @attributes[method_name]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @attributes.key?(method_name) || super
    end

    def to_h
      deep_to_h(@attributes)
    end

    def to_json(*)
      camelize_keys(to_h).to_json(*)
    end

    def apply_attributes(new_attributes)
      underscore_keys(new_attributes).each do |key, value|
        setter = "#{key}="
        if respond_to?(setter)
          send(setter, value)
        else
          @attributes[key.to_sym] = value
        end
      end
    end

    private

    def deep_to_h(value)
      case value
      when Speedy::Model
        value.to_h
      when Hash
        value.transform_values { |item| deep_to_h(item) }
      when Array
        value.map { |item| deep_to_h(item) }
      else
        value
      end
    end
  end
end
