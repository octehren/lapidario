# frozen_string_literal: true

require_relative "helper"

module Lapidario
  class LockfileInfo
    def initialize(gemfile_lock_as_strings)
      @git_gems = []
      @rubygems_gems = Lapidario::LockfileInfo.get_rubygems_from_gemfile_lock(gemfile_lock_as_strings)
      print @rubygems_gems
    end

    def puts_versionless_rubygems_info
      versionless_gems = []
      @rubygems_gems.each do |gem, version|
        versionless_gems << [gem, version] if version.nil? || version.empty?
      end
      puts versionless_gems
      puts "There are #{versionless_gems.size} gems without specified version, names are listed above."
    end

    def git_gems?
      puts "TODO"
    end

    # gets gems installed from rubygems; in the future check also for other remote sources
    def self.get_rubygems_from_gemfile_lock(gemfile_lock_as_strings)
      gem_section = []
      gem_names_and_versions = {}
      gemfile_lock_as_strings.each_with_index do |line, index|
        gem_section = Helper.slice_up_to_next_empty_line(index, gemfile_lock_as_strings) if line == "GEM"
      end

      raise "#{gemfile_lock_as_strings.join("\n")}\n\nEND OF OUTPUT\nA line consisting of a single 'GEM' string with no further chars wasn't found. See output above." if gem_section.empty?

      gem_section.each do |line|
        if Lapidario::Helper.lockfile_primary_gem_line? line
          gem_name_and_version = line.clone.strip.split(" ")
          gem_names_and_versions[gem_name_and_version[0]] = gem_name_and_version[1]
        end
      end
      gem_names_and_versions
    end
  end
end
