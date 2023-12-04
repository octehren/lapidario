# frozen_string_literal: true
require_relative "lapidario/version"
require_relative "helper"
require_relative "lockfile_info"
require_relative "gemfile_info"

module Lapidario
  class Error < StandardError; end

  def self.get_gemfile_and_lockfile_info(project_path_hash)
    project_path = project_path_hash[:project_path]
    if (project_path && !project_path.empty?)
      gemfile_path, lockfile_path = Lapidario::Helper.format_path(project_path, false), Lapidario::Helper.format_path(project_path, true)
    elsif !(project_path_hash[:gemfile_path] && !project_path_hash[:gemfile_path].empty?) && !(project_path_hash[:lockfile_path] && !project_path_hash[:lockfile_path].empty?)
      raise Lapidario::Error, "Double-check input for project path."
    else
      gemfile_path, lockfile_path = Lapidario::Helper.format_path(project_path_hash[:gemfile_path], false), Lapidario::Helper.format_path(project_path_hash[:lockfile_path], true)
    end
    
    gemfile_info = Lapidario::GemfileInfo.new(Lapidario::Helper.get_file_as_array_of_lines(gemfile_path))
    lockfile_info = Lapidario::LockfileInfo.new(Lapidario::Helper.get_file_as_array_of_lines(lockfile_path))
    [gemfile_info, lockfile_info]
  end

  def self.hardcode_lockfile_versions_into_gemfile_info(gemfile_info, lockfile_info)
    new_gemfile_info = gemfile_info.gemfile_lines_info.clone
    lockfile_primary_gems = lockfile_info.primary_gems
    # replace versions in gemfile with ones on lockfile
    new_gemfile_info.each do |gem_info|
      lock_version = lockfile_primary_gems[gem_info[:name]]
      gem_info[:current_version] = lock_version if lock_version
    end
    new_gemfile_info
  end

  def self.build_new_gemfile(new_gemfile_info, original_gemfile_lines)
    new_gemfile = original_gemfile_lines.clone
    new_gemfile_info.each do |info_item|
      new_line = Lapidario::GemfileInfo.build_gemfile_line(info_item)
      new_gemfile[info_item[:line_number]] = new_line
    end
    new_gemfile
  end
end
