# spec/lapidario/gemfile_info_spec.rb

require_relative "../spec_helper"

RSpec.describe Lapidario::GemfileInfo do
  let(:gemfile_as_strings) { -> { Lapidario::Helper.get_file_as_array_of_lines(get_random_gemfile_path) }.call }

  describe "#initialize" do
    it "creates GemfileInfo object with correct gemfile lines" do
      gemfile_info = described_class.new(gemfile_as_strings)
      expect(gemfile_info.instance_variable_get(:@gemfile_lines)).to be_an(Array)
    end
  end

  describe ".gem_info" do
    it "returns a hash with gem information" do
      gemfile_line = "gem 'rails', '~> 6.0'"
      gem_info = described_class.gem_info(gemfile_line)
      expect(gem_info[:name]).to eq('rails')
      expect(gem_info[:current_version]).to eq('6.0')
      expect(gem_info[:version_sign]).to eq('~>')
    end

    it "returns a hash with gem information while detecting extra info" do
      gemfile_line = "gem 'rails', '~> 6.0', require: false, github: 'https://github.com/rails/rails'"
      gem_info = described_class.gem_info(gemfile_line)
      expect(gem_info[:name]).to eq('rails')
      expect(gem_info[:current_version]).to eq('6.0')
      expect(gem_info[:version_sign]).to eq('~>')
      expect(gem_info[:extra_info]).to eq("require: false, github: 'https://github.com/rails/rails'")
    end

    it "returns a hash with gem information when version is blank, including extra info" do
      gemfile_line = "gem 'rails', require: false, github: 'https://github.com/rails/rails'"
      gem_info = described_class.gem_info(gemfile_line)
      expect(gem_info[:name]).to eq('rails')
      expect(gem_info[:current_version]).to eq('')
      expect(gem_info[:version_sign]).to eq("")
    end

    it "returns a hash with gem information when version is ranged" do
      gemfile_line = "gem 'rails', '>= 6.0', '< 7.0', require: false, github: 'https://github.com/rails/rails'"
      gem_info = described_class.gem_info(gemfile_line)
      expect(gem_info[:name]).to eq('rails')
      expect(gem_info[:current_version]).to eq('6.0')
      expect(gem_info[:version_sign]).to eq('>=')
      expect(gem_info[:extra_info]).to eq("'< 7.0', require: false, github: 'https://github.com/rails/rails'")
    end
  end

  describe ".construct_gemfile_line" do
    it "rebuilds line making sure upper range is first element after gem name and lower range version, if an upper range exists" do
      TODO
    end
  end

  describe ".extract_gemfile_lines_info" do
    it "returns an array of gem information hashes" do
      gemfile_lines = ["not a gem line", "gem 'rails', '~> 6.0'", "gem 'rspec', '>= 3.0'"]
      gemfile_info = Lapidario::GemfileInfo.extract_gemfile_lines_info(gemfile_lines)
      expect(gemfile_info).to be_an(Array)
      expect(gemfile_info[0][:name]).to eq('rails')
      expect(gemfile_info[1][:name]).to eq('rspec')
    end
  end

  # Add more tests as needed for other methods in GemfileInfo
end
