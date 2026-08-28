# frozen_string_literal: true

module Speedy
  class Error < StandardError
    attr_reader :error, :status

    def initialize(message = nil, error: nil, status: nil)
      @error = error
      @status = status

      super(message || error_message || status_message || self.class.name)
    end

    private

    def error_message
      return unless error.respond_to?(:full_message)

      message = error.full_message
      message unless message.to_s.strip.empty?
    end

    def status_message
      return if status.nil?

      "Speedy API request failed with status #{status}."
    end
  end
end
