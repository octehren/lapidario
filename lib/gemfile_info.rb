# frozen_string_literal: true
require_relative "helper"

module Lapidario
  class GemfileInfo
    def initialize(gemfile_as_strings)
      # array of hashes:
      # { line_number: int; is_gem_line: bool;
      # current_version: string; version_sign: string; extra_info: string}
      @gemfile_lines = Lapidario::GemfileInfo.extract_gemfile_lines_info(gemfile_as_strings)
    end


    def self.get_gem_info(gemfile_line)
      gem_info = { line_number: 0, gem_name: "", current_version: "", version_sign: "", extra_info: "" }
      gemfile_line_items = gemfile_line.split(",")
      gemfile_line_items.each_with_index do |element, index|
      end
      gem_info
    end

    def self.extract_gemfile_lines_info(gemfile_as_strings)
      gemfile_lines = []
      gemfile_as_strings.each do |line|
      gemfile_lines << Lapidario::Helper.get_gem_info if Lapidario::Helper.is_gem_line? line
      end
      gemfile_lines
    end
  end
end
