# frozen_string_literal: true

require 'rubygems'

gemspec_path = File.expand_path('../speedy-bg.gemspec', __dir__)
specification = Gem::Specification.load(gemspec_path)
abort "Could not load #{gemspec_path}" unless specification
abort "Expected gem name speedy-bg, got #{specification.name}" unless specification.name == 'speedy-bg'

required_files = %w[lib/speedy.rb lib/speedy-bg.rb sig/speedy.rbs README.md SECURITY.md CONTRIBUTING.md]
missing_files = required_files - specification.files
abort "Package is missing: #{missing_files.join(', ')}" unless missing_files.empty?

tag = ENV.fetch('GITHUB_REF', '')[%r{\Arefs/tags/(.+)\z}, 1] || ARGV.first
exit if tag.nil? || tag.empty?

expected_tag = "v#{specification.version}"
abort "Release tag #{tag.inspect} must equal #{expected_tag.inspect}" unless tag == expected_tag

puts "Release tag #{tag} matches speedy-bg #{specification.version}."
