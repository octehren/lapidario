# frozen_string_literal: true
require "lapidario"

# debugger available everywhere in tests
require "pry"

GEM_AND_LOCKFILE_NAMES = ["mastodon", "lapidario_v01"]

def get_gemfile_path(gemfile_name)
  File.join(__dir__, "fixtures/gemfile_samples", "Gemfile.#{gemfile_name}")
end

def get_lockfile_path(lockfile_name)
  File.join(__dir__, "fixtures/lockfile_samples", "Gemfile.lock.#{lockfile_name}")
end

def get_random_gemfile_path
  get_gemfile_path(GEM_AND_LOCKFILE_NAMES.sample)
end

def get_random_lockfile_path
  get_lockfile_path(GEM_AND_LOCKFILE_NAMES.sample)
end

def get_random_gemfile
  Lapidario::Helper.get_file_as_array_of_lines(get_random_gemfile_path)
end

def get_random_lockfile
  Lapidario::Helper.get_file_as_array_of_lines(get_random_lockfile_path)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
