# frozen_string_literal: true
require_relative "lapidario/version"
require_relative "helper"
require_relative "lockfile_info"
require_relative "gemfile_info"

module Lapidario
  class Error < StandardError; end

  ######################
  ## shared processes ## ex: steps for specific processes, used more than once
  ######################

  # first step: build gemfile and lockfile info instances
  # input: project_path_hash; has either :project_path key or both :gemfile_path and :lockfile_path; returns GemfileInfo and LockfileInfo instances
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

  # semi-final step: build new temporary gemfile, replacing changed lines in the original; intermediary object will be altered by one of the methods at the bottom of the page
  def self.build_new_gemfile(new_gemfile_info, original_gemfile_lines)
    new_gemfile = original_gemfile_lines.clone
    new_gemfile_info.each do |info_item|
      new_line = Lapidario::GemfileInfo.build_gemfile_line(info_item)
      new_gemfile[info_item[:line_index]] = new_line
    end
    new_gemfile
  end

  # final step: save new, backup old
  def self.save_gemfiles(save_path, new_gemfile, original_gemfile)
    # save original gemfile as backup
    original_save_path = Lapidario::Helper.format_path(save_path) + ".original"
    Lapidario::Helper.save_file(original_save_path, original_gemfile.join("\n"))
    # overwrite current Gemfile with new content
    new_save_path = Lapidario::Helper.format_path(save_path)
    Lapidario::Helper.save_file(new_save_path, new_gemfile.join("\n"))
  end

  ######################
  # specific processes # ex: specific functionality achieved through composition of shared processes
  ######################

  # loops through lockfile info, collecting versions
  # hard-codes these versions on gemfile, as they might differ from the lockfile's
  # will use '~>' as default sign and 2 as default depth
  def self.hardcode_lockfile_versions_into_gemfile_info(gemfile_info, lockfile_info, default_sign = '~>', default_depth = 2)
    new_gemfile_info = gemfile_info.gemfile_lines_info.clone
    lockfile_primary_gems = lockfile_info.primary_gems
    # replace versions in gemfile with ones on lockfile
    new_gemfile_info.each do |gem_info|
      lock_version = lockfile_primary_gems[gem_info[:name]]
      if lock_version
        gem_info[:current_version] = lock_version
        gem_info[:current_version] = Lapidario::Helper.format_version_based_on_depth(lock_version, default_depth) if default_depth
        gem_info[:version_sign] = default_sign if default_sign && !default_sign.empty?
      end
    end
    new_gemfile_info
  end

  # soft reset of gemfile, removing all version information. Removing extra info is optional
  # Note: if a version is ranged and extra info is keps, this will also hard-code the version upper range in the gem line.
  def self.hardcode_gemfile_with_empty_versions(gemfile_info, keep_extra_info = true)
    new_gemfile_info = gemfile_info.gemfile_lines_info.clone
    # replace versions in gemfile with ones on lockfile
    new_gemfile_info.each do |gem_info|
      gem_info[:current_version] = ""
      gem_info[:version_sign] = ""
      gem_info[:extra_info] = "" unless keep_extra_info
    end
    new_gemfile_info
  end
end
