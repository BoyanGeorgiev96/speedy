# frozen_string_literal: true

# Bundler derives its default require path from the gem name. Keep the public
# Ruby namespace and canonical require path unchanged while publishing the
# package as `speedy-bg`.
require_relative 'speedy'
