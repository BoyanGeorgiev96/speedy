# frozen_string_literal: true

require_relative 'lib/speedy/version'

Gem::Specification.new do |spec|
  spec.name = 'speedy'
  spec.version = Speedy::VERSION
  spec.authors = ['Boyan Georgiev']
  spec.email = ['boyan.georgiev@smartly.io']

  spec.summary = 'Ruby client for the Speedy Bulgaria REST API.'
  spec.description = 'A small Faraday-backed Ruby client for Speedy shipment calculation, labels, offices, ' \
                     'and validation.'
  spec.homepage = 'https://github.com/BoyanGeorgiev96/speedy'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .rubocop.yml])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'csv', '~> 3.3'
  spec.add_dependency 'faraday', '>= 2.14', '< 3.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
