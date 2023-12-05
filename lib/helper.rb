# frozen_string_literal: true

require "fileutils"

module Lapidario
  module Helper
    # regex to match the version fragment in a Gemfile, such as '~> 0.21', '1.2', '>= 10.2.1', '1.2alpha' etc;
    @@GEM_VERSION_FRAGMENT = /^\s*([<>]=?|~>)?\s*[0-9a-zA-Z\s.]+\s*$/
    @@DETECT_GEMFILE_IN_PATH = /\/Gemfile/
    @@DETECT_LOCKFILE_IN_PATH = /\/Gemfile\.lock/
    # checks 0 or more spaces to the left or 1 or more to the right, also asserting that LOCK is at the end of string
    @@DETECT_LOCKED_LINE = /\s*LOCK\s*\z/

    def self.version_fragment?(line_section)
      line_section.match? @@GEM_VERSION_FRAGMENT
    end

    def self.gem_line?(gemfile_line)
      commented_portion = gemfile_line.split("#", 2)[1] # gets everything to the right of a '#' if present in line
      if commented_portion && commented_portion.match?(@@DETECT_LOCKED_LINE)
        puts "Ignoring line as it ends in # LOCK: \n#{gemfile_line}"
        return false
      end
      gemfile_line.match?(/^\s*gem\s+["']([^"']+)["']/)
    end

    # formats based on depth; ex: version_fragment = '3.12.4' with depth 2 returns 3.12
    def self.format_version_based_on_depth(version_fragment, depth = 2)
      raise Lapidario::Error, "Tried to format #{version_fragment} with inadequate depth '#{depth}'." unless depth >= 1 && depth <= 3
      version_fragment.split(".").slice(0, depth).join(".")
    end

    def self.format_path(filepath, for_lockfile = false)
      # path can be ./project/, ./project or ./project/Gemfile, but never ./project/Gemfile/
      appendage = ""
      appendage = "/" unless (filepath =~ /\/$/ or filepath =~ @@DETECT_GEMFILE_IN_PATH) # checks if path finishes on '/' or if it contains Gemfile (also valid for lockfile)
      unless for_lockfile
        appendage = appendage + "Gemfile" unless filepath =~ @@DETECT_GEMFILE_IN_PATH
      else
        appendage = appendage + "Gemfile.lock" unless filepath =~ @@DETECT_LOCKFILE_IN_PATH
      end
      filepath + appendage
    end

    def self.save_file(save_path, content)
      File.write(save_path, content)
    end

    def self.get_file_as_array_of_lines(filepath)
      begin
        File.read(filepath).split("\n")
      rescue => e
        raise Lapidario::Error, "#{e.message}\n\nDouble-check the path provided for the Gemfile or Gemfile.lock\nProvided path:\n#{filepath}"
      end
    end

    # Lockfile-focused helpers
    def self.slice_up_to_next_empty_line(initial_index, lines_array)
      final_index = -1
      (initial_index...lines_array.size).each do |i|
        final_index = i if lines_array[i].empty?
      end
      raise Lapidario::Error, "Gemfile.lock should have an empty line as the last line in the file." if final_index < 0
      lines_array.slice(initial_index, final_index)
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
