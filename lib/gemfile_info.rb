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

    # detects version field, removes it from array and returns it
    def self.pop_version_field!(gemfile_line_items)
      version_index = 0
      version_number_and_sign = []
      gemfile_line_items
        .map { |item| item.gsub('"', "").gsub("'", "").gsub(" ", "") } # can be something like [" '~> 6.3'"]
        .each_with_index do |item, index| 
          if Lapidario::Helper.version_fragment? item
            version_number_and_sign = item
            version_index = index
            break # will break at first index, so if there is an upper range index later this won't affect results
          end
        end

      return [] if version_number_and_sign.empty?
      
      version_number = version_number_and_sign.gsub(/(~>|>=|<=|>|<)/, "")
      version_sign = version_number_and_sign.gsub(/[^~>=<]/, "")
      
      gemfile_line_items.delete_at(version_index)
      [version_number, version_sign]
    end

    def self.gem_info(gemfile_line, line_index = -9999)
      gem_info = { line_index: line_index, name: "", current_version: "", version_sign: "", extra_info: "" }
      gemfile_line_items = gemfile_line.split(",")
      # first element will always be gem name, so return and remove it with shift
      gem_info[:name] = Lapidario::GemfileInfo.get_gem_name gemfile_line_items.shift
      # second might not be the version number, so find the version, store it separetly and remove it from the rest of the line
      version_number_and_sign = Lapidario::GemfileInfo.pop_version_field!(gemfile_line_items)
      # to_s will make a nil value an empty string
      gem_info[:current_version] = version_number_and_sign[0].to_s
      gem_info[:version_sign] = version_number_and_sign[1].to_s
      # in case version is ranged, run pop_version_field! again, just removing the field and appending it to the beginning of extra info, immediately after lower range.
      version_upper_range = Lapidario::GemfileInfo.pop_version_field!(gemfile_line_items)
      gemfile_line_items.unshift("'#{version_upper_range[1]} #{version_upper_range[0]}'") unless version_upper_range.empty?
      # all that's left is extra_info
      gem_info[:extra_info] = gemfile_line_items.compact.join(", ").split(",").join(", ").gsub(/\s+/, ' ').strip
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
      "gem '#{gi[:name]}', '#{gi[:version_sign]} #{gi[:current_version]}', #{gi[:extra_info]}"
    end
  end
end
