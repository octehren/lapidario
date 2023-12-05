# frozen_string_literal: true
require "optparse"
require_relative "lapidario"

module Lapidario
  module CLI
    def self.start(_cmd_args)
      if _cmd_args.include?('--help') || _cmd_args.include?('-h')
        puts "Usage: lapidario [options]"
        puts "NOTE: if you want to exclude any gem in your Gemfile to the functionality described below, comment 'LOCK' at the end of its line."
        puts "Valid example of locking gem line:"
        puts "gem 'rails', '~> 7.0' # LOCK"
        puts "Invalid example of locking gem line:"
        puts "gem 'rails', '~> 7.0' # Not locked, will be taken into account to rebuild Gemfile"
        puts "Options:"
        puts "  --help, -h           Show help message"
        puts "  --lock, -l           Rebuild Gemfile using versions specified in Gemfile.lock; default sign is '~>' and default depth is 2 (up to minor, ignores patch)"
        puts "  --reset, -r          Rebuild Gemfile without gem versions"
        puts "  --full-reset, -fr    Rebuild Gemfile, removing all info but gem names"
        exit
      end
      puts "cmd args: #{_cmd_args}"
      project_path_hash = { project_path: './' }
      info_instances = Lapidario.get_gemfile_and_lockfile_info(project_path_hash)
      gemfile_info = info_instances[0]
      lockfile_info = info_instances[1]
      original_gemfile_lines = gemfile_info.original_gemfile
      new_gemfile_info = case
      when _cmd_args.include?('--reset'), _cmd_args.include?('-r')
        Lapidario.hardcode_gemfile_with_empty_versions(gemfile_info, true) # keep_extra_info = true
      when _cmd_args.include?('--full-reset'), _cmd_args.include?('-fr')
        Lapidario.hardcode_gemfile_with_empty_versions(gemfile_info, false) # keep_extra_info = false
      else # default = --lock
        Lapidario.hardcode_lockfile_versions_into_gemfile_info(gemfile_info, lockfile_info)
      end

      new_gemfile = Lapidario.build_new_gemfile(new_gemfile_info, original_gemfile_lines)
      puts "New gemfile created:"
      puts new_gemfile
      puts "In case it does not look right, check for Gemfile.original in the same directory."
    end
  end
end
