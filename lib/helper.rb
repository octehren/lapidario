# frozen_string_literal: true

require "fileutils"

module Lapidario
  module Helper
    # regex to match the version fragment in a Gemfile, such as '~> 0.21', '1.2', '>= 10.2.1', '1.2alpha' etc; 
    @@GEM_VERSION_FRAGMENT = /^\s*([<>]=?|~>)?\s*[0-9a-zA-Z\s.]+\s*$/
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

    # a primary gem line will always begin with 4 whitespaces.
    def self.lockfile_primary_gem_line?(line)
        # \A: Asserts the start of the string.
        # \x20: represents a whitespace character; whitespace is char 32 in ascii, 20 is 32 in hex
        # {4}: Indicates exactly 4 occurrences of the preceding character (whitespace in this case).
        line.match?(/\A\x20{4}[A-Za-z0-9]/)
    end
  end
end
