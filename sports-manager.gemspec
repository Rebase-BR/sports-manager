# frozen_string_literal: true

require_relative 'lib/sports_manager/version'

Gem::Specification.new do |spec|
  spec.name = 'sports-manager'
  spec.version = SportsManager::VERSION
  spec.authors = ['André Benjamim', 'Gustavo Alberto']
  spec.email = ['andre.benjamim@rebase.com.br', 'gustavo.costa@rebase.com.br']

  spec.summary = 'A Ruby tournament schedule generator tool.'
  spec.description = 'This gem generates a tournament schedule based on a list of variables.'
  spec.homepage = 'https://github.com/Rebase-BR/csp-resolver/tree/main'
  spec.required_ruby_version = '>= 2.5.8'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Rebase-BR/csp-resolver/tree/main'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'csp-resolver', '~> 0.0.1'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
