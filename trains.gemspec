# frozen_string_literal: true

require_relative 'lib/trains/version'

Gem::Specification.new do |spec|
  spec.name = 'trains'
  spec.version = Trains::VERSION
  spec.authors = ['Syed Faraaz Ahmad']
  spec.email = ['faraaz98@live.com']

  spec.summary =
    'Collect metadata about your Rails app by statically analyzing it'
  spec.homepage = 'https://github.com/faraazahmad/trains'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "https://github.com/faraazahmad/trains/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(__dir__) do
      `git ls-files -z`.split("\x0")
                       .reject do |f|
        (f == __FILE__) ||
          f.match(
            %r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)}
          )
      end
    end
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 7.0'
  spec.add_dependency 'parallel', '~> 1.22'
  spec.add_dependency 'rubocop-ast', '~> 1.16'
  spec.add_dependency 'zeitwerk', '~> 2.5'
end
