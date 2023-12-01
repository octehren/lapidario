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

    def self.get_gem_name(gem_name_item)
      gem_name_item.sub("gem ", "").gsub("'", "")
    end

    def self.get_version_field(gemfile_line_items)
      version_number_and_sign = gemfile_line_items
                                .map { |item| item.gsub('"', "").gsub("'", "").gsub(" ", "") } # can be something like [" '~> 6.3'"]
                                .find { |item| Lapidario::Helper.version_fragment? item }
      return ["", ""] unless version_number_and_sign

      version_number = version_number_and_sign.gsub(/(~>|>=|<=|>|<)/, "")
      version_sign = version_number_and_sign.gsub(/[^~>=<]/, "")
      [version_number, version_sign]
    end

    def self.gem_info(gemfile_line, line_index = -9999)
      gem_info = { line_index: line_index, name: "", current_version: "", version_sign: "", extra_info: "" }
      gemfile_line_items = gemfile_line.split(",")
      # first element will always be gem name, so return and remove it with shift
      gem_info[:name] = Lapidario::GemfileInfo.get_gem_name gemfile_line_items.shift
      version_number_and_sign = Lapidario::GemfileInfo.get_version_field(gemfile_line_items)
      gem_info[:current_version] = version_number_and_sign[0]
      gem_info[:version_sign] = version_number_and_sign[1]
      gemfile_line_items.delete(version_number_and_sign)
      # all that's left is extra_info
      gem_info[:extra_info] = gemfile_line_items.join(", ")
      gem_info
    end

    def self.extract_gemfile_lines_info(gemfile_as_strings)
      gemfile_lines = []
      gemfile_as_strings.each_with_index do |line, index|
        gemfile_lines << Lapidario::GemfileInfo.gem_info(line, index) if Lapidario::Helper.gem_line? line
      end
      gemfile_lines
    end

    def self.build_gemfile_line(gi) # gi = gem_info
      "gem '#{gi[:name]}', '#{gi[:version_sign]} #{gi[:current_version]}', #{gi[:extra_info].split(",").join(", ").gsub(/\s+/, ' ').strip}"
    end
  end
end
