# frozen_string_literal: true

require_relative "lib/lapidario/version"

Gem::Specification.new do |spec|
  spec.name = "lapidario"
  spec.version = Lapidario::VERSION
  spec.authors = ["octehren"]
  spec.email = ["ehren.dev.mail@gmail.com"]

  spec.summary = "Auxiliary for bulk updates of gems in a project."
  spec.description = "Lapidario is a Gemfile and Gemfile.lock static analyzer that helps with bulk updates and explicit version hard-coding of gems in a project. See https://github.com/octehren/lapidario for more."
  spec.homepage = "https://github.com/octehren/lapidario"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/octehren/lapidario"
  spec.metadata["changelog_uri"] = "https://github.com/octehren/lapidario/blob/master/CHANGELOG.md" # Put your gem's CHANGELOG.md URL here.

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[test/ spec/ features/ .git .circleci appveyor])
    end
  end
  # spec.bindir = "exe"
  spec.require_paths = ["lib", "bin"]
  spec.executables = ["lapidario"]


  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rspec", "~> 3.12"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
