# frozen_string_literal: true

require_relative 'lib/mutations_job/version'

Gem::Specification.new do |spec|
  spec.name = 'mutations_job'
  spec.version = MutationsJob::VERSION
  spec.authors = ['Nikolay Moskvin']
  spec.email = ['nikolay.moskvin@gmail.com']

  spec.summary = 'Just simple glue between Mutations properties and Sidekiq jobs.'
  spec.description = 'This project aims to create a seamless and straightforward connection, or "glue," between Mutations properties and Sidekiq jobs. Mutations, often used in Ruby on Rails applications, are responsible for handling data input and validation. On the other hand, Sidekiq is a popular background job processing library used to execute time-consuming tasks asynchronously.'
  spec.homepage = 'https://github.com/moskvin/mutations_job'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['allowed_push_host'] = 'https://github.com/moskvin/mutations_job'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/moskvin/mutations_job'
  spec.metadata['changelog_uri'] = 'https://github.com/moskvin/mutations_job/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 7.0'
  spec.add_dependency 'mutations', '~> 0.9'
  spec.add_dependency 'sidekiq', '~> 7.0'
end
