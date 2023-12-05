# frozen_string_literal: true
require "optparse"
require_relative "lapidario"

module Lapidario
  module CLI
    def self.start(_cmd_args)
      puts "cmd args: #{_cmd_args}"
      project_path_hash = { project_path: './' }
      info_instances = Lapidario.get_gemfile_and_lockfile_info(project_path_hash)
      gemfile_info = info_instances[0]
      lockfile_info = info_instances[1]
      original_gemfile_lines = gemfile_info.original_gemfile
      new_gemfile_info = Lapidario.hardcode_lockfile_versions_into_gemfile_info(gemfile_info, lockfile_info)
      new_gemfile = Lapidario.build_new_gemfile(new_gemfile_info, original_gemfile_lines)
      puts "New gemfile created:"
      puts new_gemfile
      puts "In case it does not look right, check for Gemfile.original in the same directory."
    end
  end
end
