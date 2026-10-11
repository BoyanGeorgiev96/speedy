# frozen_string_literal: true

require_relative 'lib/speedy/version'

Gem::Specification.new do |spec|
  spec.name = 'speedy-bg'
  spec.version = Speedy::VERSION
  spec.authors = ['Boyan Georgiev']
  spec.email = ['boyan.georgiev@smartly.io']

  spec.summary = 'Ruby client for the Speedy Bulgaria REST API.'
  spec.description = 'A Faraday-backed Ruby client for Speedy shipments, labels, tracking, locations, ' \
                     'pickups, clients, contracts, and payouts.'
  spec.homepage = 'https://github.com/BoyanGeorgiev96/speedy'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/tree/main"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['documentation_uri'] = "#{spec.homepage}/blob/main/docs/API.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    Dir[
      'lib/**/*', 'sig/**/*', 'docs/**/*',
      'CHANGELOG.md', 'CODE_OF_CONDUCT.md', 'CONTRIBUTING.md', 'LICENSE.txt', 'README.md', 'SECURITY.md'
    ]
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'csv', '~> 3.3'
  spec.add_dependency 'faraday', '>= 2.14', '< 3.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
