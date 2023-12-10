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
      @version_depth ||= 2
      @version_sign ||= '~>'
      @save_new_gemfile ||= false
      @save_backup ||= true if @save_backup.nil? # conditional assignment also executes on non-nil falsey values
    end

    def parse_options(options)
      # Create an OptionParser object
      opt_parser = OptionParser.new do |opts|
        opts.on("-h", "--help", "Show help message") do
          Lapidario::CLI.output_help_and_exit
        end

        opts.on("-p", "--path STRING", "Define path in which Gemfile and Lockfile are located. Defaults to current directory") do |project_path|
          @project_path_hash = { project_path: project_path }
        end

        opts.on("-r", "--reset", "Rebuild Gemfile without gem versions") do
          @reset_gemfile = true
        end

        opts.on("-fr", "--full-reset", "Rebuild Gemfile, removing all info but gem names") do
          @full_reset_gemfile = true
        end

        opts.on("-w", "--write", "Writes command output to Gemfile. Backs up previous Gemfile in Gemfile.original, remember to remove it later") do
          @save_new_gemfile = true
        end

        opts.on("-sb", "--skip-backup", "Skips creation of backup Gemfile.original if writing to Gemfile") do
          @save_backup = false
        end

        opts.on("-d", "--depth NUMBER", "Select depth (major = 1, minor = 2, patch = 3) of version string; min = 1, max = 3, default = 2") do |depth|
          @version_depth = depth.to_i
        end

        opts.on("-vs", "--version-sign NUMBER", "Select sign to use for version specification (default = '~>') (0 = '~>', 1 = '>=', 2 = '<=', 3 = '>', 4 = '<', 5 = no sign)") do |sign|
          @version_sign = Lapidario::Helper.get_version_sign_from_number(sign.to_i)
        end
      end

      # Parse the command-line arguments
      opt_parser.parse!(options)
    end

    def start
      info_instances = Lapidario.get_gemfile_and_lockfile_info(@project_path_hash)
      gemfile_info = info_instances[0]
      lockfile_info = info_instances[1]
      original_gemfile_lines = gemfile_info.original_gemfile
      new_gemfile_info = case
        when @reset_gemfile
          Lapidario.hardcode_gemfile_with_empty_versions(gemfile_info, true) # keep_extra_info = true
        when @full_reset_gemfile
          Lapidario.hardcode_gemfile_with_empty_versions(gemfile_info, false) # keep_extra_info = false
        else # default = --lock
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

    def self.output_help_and_exit
      puts "Usage: lapidario [options]\n\n"
      puts "NOTE: if you want to exclude any gem in your Gemfile to the functionality described below, comment 'LOCK' at the end of its line.\nSee examples:\n\n"
      puts "Valid example of locking gem line:\n"
      puts "gem 'rails', '~> 7.0' # LOCK"
      puts "\n\nInvalid example of locking gem line:"
      puts "gem 'rails', '~> 7.0' # Not locked, will be taken into account to rebuild Gemfile"
      puts "\n\nOptions:"
      puts "  --help, -h                    Show help message"
      puts "  --lock, -l                    Rebuild Gemfile using versions specified in Gemfile.lock; default sign is '~>' and default depth is 2 (up to minor version, ignores patch)"
      puts "  --reset, -r                   Rebuild Gemfile without gem versions"
      puts "  --full-reset, -fr             Rebuild Gemfile, removing all info but gem names"
      puts "  --depth, -d NUMBER            Select depth (major = 1, minor = 2, patch = 3) of version string; min = 1, max = 3, default = 2"
      puts "  --version-sign, -vs NUMBER    Select sign to use for version specification (default = '~>') (0 = '~>', 1 = '>=', 2 = '<=', 3 = '>', 4 = '<', 5 = no sign)"
      puts "  --path, -p                    Define path in which Gemfile and Lockfile are located. Defaults to current directory"
      puts "  --write, -w                   Writes command output to Gemfile. Keeps previous Gemfile in Gemfile.original, remember to remove it"
      puts "  --skip-backup, -sb            Skips creation of backup Gemfile.original if writing to gemfile"
      exit
    end
  end
end
