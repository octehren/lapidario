# frozen_string_literal: true

require_relative "lapidario/version"
require_relative "helper"
require_relative "lockfile_info"
require_relative "gemfile_info"
module Lapidario
  class Error < StandardError; end

  def self.get_gemfile_lock_info(gemfile_lock_path)
    gemfile_lock = Helper.get_file_as_array_of_lines(gemfile_lock_path)
    GemfileLockInfo.new(gemfile_lock)
  end

  def self.hardcode_lockfile_versions_into_gemfile
    puts "TODO"
  end
end
