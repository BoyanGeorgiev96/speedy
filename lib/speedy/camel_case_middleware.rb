# frozen_string_literal: true

require 'faraday'

module Speedy
  class CamelCaseMiddleware < Faraday::Middleware
    DEFAULT_ACRONYMS = {
      'id' => 'Id',
      'ids' => 'Ids',
      'cod' => 'COD',
      'pudo' => 'PUDO'
    }.freeze

    def initialize(app, acronyms: {}, replace_defaults: false)
      super(app)
      @acronyms =
        if acronyms.nil?
          {}
        elsif replace_defaults
          acronyms.transform_keys(&:to_s)
        else
          DEFAULT_ACRONYMS.merge(acronyms.transform_keys(&:to_s))
        end
      @acronym_reverse = @acronyms.each_with_object({}) { |(key, value), hash| hash[value] = key }
    end

    def call(env)
      env.body = deep_transform_keys(env.body) { |key| to_camel_case(key) } if env.body.is_a?(Hash)
      @app.call(env)
    end

    def on_complete(env)
      env.body = deep_transform_keys(env.body) { |key| to_snake_case(key) } if env.body.is_a?(Hash)
    end

    private

    def to_camel_case(key)
      parts = key.to_s.split('_')
      first = parts.shift

      first + parts.map { |part| @acronyms.fetch(part, part.capitalize) }.join
    end

    def to_snake_case(key)
      str = key.to_s
      @acronym_reverse.keys.sort_by { |acro| -acro.length }.each do |acro|
        str = str.gsub(/#{acro}(?=[A-Z]|$)/) { "_#{@acronym_reverse[acro]}_" }
      end

      str
        .gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .downcase
        .gsub(/__+/, '_')
        .sub(/^_/, '')
        .sub(/_$/, '')
    end

    def deep_transform_keys(obj, &block)
      case obj
      when Array
        obj.map { |item| deep_transform_keys(item, &block) }
      when Hash
        obj.each_with_object({}) { |(key, value), hash| hash[yield(key)] = deep_transform_keys(value, &block) }
      else
        obj
      end
    end
  end
end
