# frozen_string_literal: true

require "fileutils"

module Lapidario
  module Helper
    # regex to match the version fragment in a Gemfile, such as '~> 0.21', '1.2', '>= 10.2.1', '== 1.2alpha' etc
    @@GEM_VERSION_FRAGMENT = /^[0-9\s.~><=]+$|^((~>|>=|<=|=)([0-9a-zA-Z\s.]*))+$|^([0-9a-zA-Z\s.]*)(<|>)([0-9a-zA-Z\s.]*)+$/

    # GemfileInfo helpers

    def self.version_fragment?(line_section)
        line_section.match? @@GEM_VERSION_FRAGMENT
    end

    def self.gem_line?(gemfile_line)
        gemfile_line.start_with? "gem "
    end

    # GemfileLockInfo helpers

    def self.get_file_as_array_of_lines(filepath)
        File.read(filepath).split("\n")
    end

    def self.slice_up_to_next_empty_line(initial_index, lines_array)
        final_index = -1
        (initial_index...lines_array.size).each do |i|
        final_index = i if lines_array[i].empty?
        end
        lines_array.slice(initial_index, final_index)
    end

    def self.get_git_gems_from_gemfile_lock(_gemfile_lock_as_strings)
        puts "TODO"
    end

    # gets gems installed from rubygems; in the future check also for other remote sources
    def self.get_rubygems_from_gemfile_lock(gemfile_lock_as_strings)
        gem_section = []
        gem_names_and_versions = {}
        gemfile_lock_as_strings.each_with_index do |line, index|
        gem_section = Helper.slice_up_to_next_empty_line(index, gemfile_lock_as_strings) if line == "GEM"
        end
        gem_section.each do |line|
        if Helper.is_primary_gem_line? line
            gem_name_and_version = line.clone.strip.split(" ")
            gem_names_and_versions[gem_name_and_version[0]] = gem_name_and_version[1]
        end
        end
        gem_names_and_versions
    end

    # a primary gem line will always begin with 4 whitespaces.
    def self.lockfile_primary_gem_line?(line)
        # \A: Asserts the start of the string.
        # \x20: represents a whitespace character; whitespace is char 32 in ascii, 20 is 32 in hex
        # {4}: Indicates exactly 4 occurrences of the preceding character (whitespace in this case).
        line.match?(/\A\x20{4}[A-Za-z0-9]/)
    end
  end
end
