# frozen_string_literal: true

require_relative "helper"

module Lapidario
  class LockfileInfo
    def initialize(gemfile_lock_as_strings)
      @git_gems = []
      @rubygems_gems = Lapidario::Helper.get_rubygems_from_gemfile_lock(gemfile_lock_as_strings)
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
  end
end
