# frozen_string_literal: true

require_relative "lib/lapidario/version"

Gem::Specification.new do |spec|
  spec.name = "lapidario"
  spec.version = Lapidario::VERSION
  spec.authors = ["octehren"]
  spec.email = ["ehren.dev.mail@gmail.com"]

  spec.summary = "Auxiliary for bulk updates of gems in a project."
  spec.description = "Lapidario is a Gemfile and Gemfile.lock static analyzer that helps with bulk updates of gems in a project. As of version 0.1, run it in a directory with both a Gemfile and Gemfile.lock to hard-code the locked versions in Gemfile.lock to the Gemfile."
  spec.homepage = "https://example.com"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://example.com"
  spec.metadata["changelog_uri"] = "https://example.com" # Put your gem's CHANGELOG.md URL here.

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.require_paths = ["lib", "bin"]
  spec.executables = spec.files.grep(spec.name) { |f| File.basename(f) }


  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rspec", "~> 3.12"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
