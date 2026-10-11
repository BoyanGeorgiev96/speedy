# frozen_string_literal: true

require 'bundler/setup'
require 'open3'
require 'rubygems/package'
require 'tmpdir'

ROOT = File.expand_path('..', __dir__)

def run!(*command, env: {}, directory: ROOT)
  output, status = Open3.capture2e(env, *command, chdir: directory)
  abort output unless status.success?
end

def check_package!(artifact)
  files = Gem::Package.new(artifact).spec.files
  required = %w[lib/speedy.rb lib/speedy-bg.rb lib/speedy/version.rb sig/speedy.rbs
                README.md LICENSE.txt SECURITY.md CONTRIBUTING.md docs/API.md docs/VCR.md docs/RESPONSE_CONTRACTS.md]
  missing = required - files
  abort "Missing packaged files: #{missing.join(', ')}" unless missing.empty?

  forbidden = files.grep(%r{(?:\A|/)(?:\.env(?:\..*)?|\.git|AGENTS\.md|spec|schema)(?:/|\z)})
  abort "Forbidden packaged files: #{forbidden.join(', ')}" unless forbidden.empty?

  check_allowed_files!(files)
end

def check_allowed_files!(files)
  allowed = %r{\A(?:lib/.+\.rb|sig/.+\.rbs|docs/.+\.md|
    (?:README|SECURITY|CONTRIBUTING|CHANGELOG|CODE_OF_CONDUCT)\.md|LICENSE\.txt)\z}x
  unexpected = files.grep_v(allowed)
  abort "Unexpected packaged files: #{unexpected.join(', ')}" unless unexpected.empty?
end

def isolated_environment(gem_home, dependency_paths)
  {
    'BUNDLE_GEMFILE' => nil,
    'GEM_HOME' => gem_home,
    'GEM_PATH' => [gem_home, *dependency_paths, *Gem.path].uniq.join(File::PATH_SEPARATOR),
    'RUBYLIB' => nil,
    'RUBYOPT' => nil
  }
end

def smoke_program(gem_home, version)
  <<~RUBY
    require 'speedy-bg'
    abort 'Speedy was not loaded' unless defined?(Speedy::Client)
    installed = Gem.loaded_specs.fetch('speedy-bg')
    expected_version = #{version.inspect}
    abort 'unexpected package version' unless installed.version.to_s == expected_version
    abort 'unexpected runtime version' unless Speedy::VERSION == expected_version
    temporary_home = File.realpath(#{gem_home.inspect}) + File::SEPARATOR
    installed_path = File.realpath(installed.full_gem_path)
    abort 'Loaded gem outside temporary GEM_HOME' unless installed_path.start_with?(temporary_home)
    source_path = File.realpath($LOADED_FEATURES.find { |path| path.end_with?('/speedy.rb') })
    abort 'Loaded source outside installed artifact' unless source_path.start_with?(installed_path + File::SEPARATOR)
  RUBY
end

spec = Gem::Specification.load(File.join(ROOT, 'speedy-bg.gemspec'))
abort 'Could not load speedy-bg.gemspec' unless spec

# Bundler can install dependencies outside RubyGems' ordinary search paths.
dependency_paths = Bundler.load.specs.reject { |dependency| dependency.name == spec.name }.map(&:base_dir)

Dir.mktmpdir('speedy-bg-package') do |directory|
  artifact = File.join(directory, "#{spec.full_name}.gem")
  gem_home = File.join(directory, 'gem-home')
  run!(Gem.ruby, '-S', 'gem', 'build', 'speedy-bg.gemspec', '--output', artifact)
  check_package!(artifact)
  run!(Gem.ruby, '-S', 'gem', 'install', '--local', '--ignore-dependencies', '--no-document',
       '--install-dir', gem_home, artifact)
  run!(Gem.ruby, '-e', smoke_program(gem_home, spec.version.to_s),
       env: isolated_environment(gem_home, dependency_paths), directory: directory)
end

puts 'Built, installed, and loaded speedy-bg successfully.'
