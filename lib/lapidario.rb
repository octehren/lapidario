# frozen_string_literal: true
require "pry"
require_relative "lapidario/version"
require_relative "helper"
require_relative "lockfile_info"
require_relative "gemfile_info"

module Lapidario
  class Error < StandardError; end

  def self.get_gemfile_lock_info(gemfile_lock_path)
    # gemfile_lock = Helper.get_file_as_array_of_lines(gemfile_lock_path)
    # GemfileLockInfo.new(gemfile_lock)
  end
  # project_path_hash = {}
  # project_path_hash[:gemfile_path] = "/Users/Otavio_Ehrenberger/Documents/DevelopingLibraries/Ruby/lapidario/spec/fixtures/gemfile_samples/Gemfile.lapidario_v01"
  # project_path_hash[:lockfile_path] = "/Users/Otavio_Ehrenberger/Documents/DevelopingLibraries/Ruby/lapidario/spec/fixtures/lockfile_samples/Gemfile.lock.lapidario_v01"
  # Lapidario.hardcode_lockfile_versions_into_gemfile(project_path_hash)
  def self.hardcode_lockfile_versions_into_gemfile(project_path_hash)
    project_path = project_path_hash[:project_path]
    if (project_path)
      gemfile_path, lockfile_path = Lapidario::Helper.format_path(project_path, false), Lapidario::Helper.format_path(project_path, true)
    else
      gemfile_path, lockfile_path = Lapidario::Helper.format_path(project_path_hash[:gemfile_path], false), Lapidario::Helper.format_path(project_path_hash[:lockfile_path], true)
    end
    
    gemfile_info = Lapidario::GemfileInfo.new(Lapidario::Helper.get_file_as_array_of_lines(gemfile_path))
    lockfile_info = Lapidario::LockfileInfo.new(Lapidario::Helper.get_file_as_array_of_lines(lockfile_path))
    binding.pry
  end
end

project_path_hash = {}
project_path_hash[:gemfile_path] = "/Users/Otavio_Ehrenberger/Documents/DevelopingLibraries/Ruby/lapidario/spec/fixtures/gemfile_samples/Gemfile.lapidario_v01"
project_path_hash[:lockfile_path] = "/Users/Otavio_Ehrenberger/Documents/DevelopingLibraries/Ruby/lapidario/spec/fixtures/lockfile_samples/Gemfile.lock.lapidario_v01"
Lapidario.hardcode_lockfile_versions_into_gemfile(project_path_hash)