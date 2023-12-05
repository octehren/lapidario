# frozen_string_literal: true
require "optparse"
require_relative "lapidario"

module Lapidario
  module CLI
    def self.start(_cmd_args)
      puts "cmd args: #{_cmd_args}"
    end
  end
end
