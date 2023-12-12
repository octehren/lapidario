# frozen_string_literal: true
require "optparse"
require_relative "lapidario"

module Lapidario
  class CLI
    def initialize(_cmd_args)
      parse_options(_cmd_args) # will initialize variables below if options are passed
      @project_path_hash ||= { project_path: './' }
      @reset_gemfile ||= false
      @full_reset_gemfile ||= false
      @lock_gemfile ||= true unless @reset_gemfile || @full_reset_gemfile
      @version_depth ||= 2
      @version_sign ||= '~>'
      @save_new_gemfile ||= false
      @save_backup ||= true if @save_backup.nil? # conditional assignment also executes on non-nil falsey values
      @include_git_gems ||= false
    end

    def parse_options(options)
      opt_parser = OptionParser.new do |opts|
        opts.on("-h", "--help", "Show help message") do
          puts "NOTE: if you want to exclude any gem in your Gemfile to the functionality described below, comment 'LOCK' at the end of its line.\nSee examples:\n\n"
          puts "Valid example of locking gem line:\n"
          puts "gem 'rails', '~> 7.0' # LOCK"
          puts "\nInvalid example of locking gem line:"
          puts "gem 'rails', '~> 7.0' # Not locked, will be taken into account to rebuild Gemfile\n\n"
          puts opts
          exit
        end

        opts.on("-w", "--write", "Write command output to Gemfile. Backs up previous Gemfile to new file Gemfile.original") do
          @save_new_gemfile = true
        end

        opts.on("-s", "--skip-backup", "Skips creation of backup Gemfile.original if writing to Gemfile") do
          @save_backup = false
        end

        opts.on("-d", "--depth NUMBER", "Select depth (major = 1, minor = 2, patch = 3) of version string; min = 1, max = 3, default = 2") do |depth|
          @version_depth = depth.to_i
        end

        opts.on("-v", "--version-sign NUMBER", "Select sign to use for version specification (default = '~>') (0 = '~>', 1 = '>=', 2 = '<=', 3 = '>', 4 = '<', 5 = no sign)") do |sign|
          @version_sign = Lapidario::Helper.get_version_sign_from_number(sign.to_i)
        end

        opts.on("-p", "--path STRING", "Define path in which Gemfile and Lockfile are located. Defaults to current directory") do |project_path|
          @project_path_hash = { project_path: project_path }
        end

        opts.on("-g", "--git-gems", "Include GIT gems from Gemfile.lock in Gemfile reconstruction") do
          @include_git_gems = true
        end

        opts.on("-l", "--lock", "Rebuild Gemfile using versions specified in Gemfile.lock; default sign is '~>' and default depth is 2 (major & minor versions, ignores patch)") do
          @lock_gemfile = true
        end

        opts.on("-r", "--reset", "Rebuild Gemfile without gem versions") do
          @reset_gemfile = true
        end

        opts.on("-f", "--full-reset", "Rebuild Gemfile, removing all info but gem names") do
          @full_reset_gemfile = true
        end
      end

      if options.empty?
        puts "Run `lapidario --help` if you would like to check the command line options or visit https://github.com/octehren/lapidario for a more in-depth explanation of the gem."
        exit
      end

      # Parse the command-line arguments
      opt_parser.parse!(options)
    end

    def start
      info_instances = Lapidario.get_gemfile_and_lockfile_info(@project_path_hash, @include_git_gems)
      gemfile_info = info_instances[0]
      lockfile_info = info_instances[1]
      original_gemfile_lines = gemfile_info.original_gemfile
      new_gemfile_info = case
        when @reset_gemfile
          Lapidario.hardcode_gemfile_with_empty_versions(gemfile_info, true) # keep_extra_info = true
        when @full_reset_gemfile
          Lapidario.hardcode_gemfile_with_empty_versions(gemfile_info, false) # keep_extra_info = false
        when @lock_gemfile # default = --lock
          Lapidario.hardcode_lockfile_versions_into_gemfile_info(gemfile_info, lockfile_info, @version_sign, @version_depth)
        end

      new_gemfile = Lapidario.build_new_gemfile(new_gemfile_info, original_gemfile_lines)
      puts "New gemfile created:\n\n================================== GEMFILE START =================================="
      puts new_gemfile
      puts "================================== GEMFILE END ==================================\n\nIn case it does not look right, check for Gemfile.original in the same directory if you are writing to the Gemfile and did not cancel the backup."
      if @save_new_gemfile
        begin
          save_path = Lapidario::Helper.format_path(@project_path_hash[:project_path], false)
          Lapidario::Helper.save_file(save_path, new_gemfile.join("\n"))
          if @save_backup
            Lapidario::Helper.save_file(save_path + ".original", original_gemfile_lines.join("\n")) 
            puts "\n\nSaved backup to #{save_path}.original\n\n"
          end
        rescue => e
          puts "Failed to save file: #{e.message}"
          raise e
        end
        puts "Saved new Gemfile to #{save_path}"
      end
    end
  end
end
