# frozen_string_literal: true

require_relative 'lib/net_suite/version'

Gem::Specification.new do |spec|
  spec.name = 'net_suite'
  spec.version = NetSuite::VERSION
  spec.authors = ['Care/of Vitamins']
  spec.email = ['dev@takecareof.com']

  spec.summary = 'NetSuite API Client'
  spec.description = 'Care/of’s gem for working with NetSuite’s API and OAuth 2.0 authentication'
  spec.homepage = 'https://github.com/careofvitamins/net_suite'
  spec.required_ruby_version = '>= 3.1.2'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 6.1'
  spec.add_dependency 'attr_extras', '~> 6.2'
  spec.add_dependency 'faraday', '>= 1.10', '< 3'
  spec.add_dependency 'jwt', '~> 2.2'
  spec.add_dependency 'oauth2', '~> 2.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
