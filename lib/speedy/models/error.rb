# frozen_string_literal: true

module Speedy
  module Models
    class Error < Speedy::Model
      field :context, type: :string
      field :message, type: :string
      field :id, type: :string
      field :code, type: :integer
      field :component, type: :string

      class << self
        def build_from(source)
          error_source = error_source_from(source)
          return unless error_source

          new(error_source)
        end

        private

        def error_source_from(source)
          return unless source.is_a?(Hash)

          root_error = source[:error] || source['error']
          return root_error if root_error.is_a?(Hash)

          source if source.key?(:message) || source.key?('message')
        end
      end

      def full_message
        [message, context].reject { |value| value.to_s.strip.empty? }.join(' ')
      end
    end
  end
end
