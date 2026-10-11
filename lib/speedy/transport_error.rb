# frozen_string_literal: true

module Speedy
  # A network failure with no usable HTTP response. The original exception is
  # retained as cause; inspect it carefully because it may contain private data.
  class TransportError < Error; end

  # The API connection could not be established or was interrupted.
  class ConnectionError < TransportError; end

  # An API request exceeded its configured connection/read/write timeout.
  # A timeout does not establish whether a remote mutation took effect.
  class TimeoutError < TransportError; end

  # TLS negotiation or certificate verification failed.
  class SSLError < TransportError; end
end
