# spec/lapidario/gemfile_info_spec.rb

require_relative "../spec_helper"

SIMPLE_GEMFILE_NAME = "lapidario_v01"
FINAL_SIMPLE_GEMFILE_NAME = "lapidario_v01.hardcoded_from_lockfile"

RSpec.describe Lapidario::GemfileInfo do
  let(:gemfile_as_array_of_strings) { -> { get_random_gemfile }.call }
  let(:gemfile_info) { described_class.new(gemfile_as_array_of_strings) }

  let(:simple_gemfile_final) { get_final_gemfile_stringified(SIMPLE_GEMFILE_NAME) }
  
  describe "class and instance method functionality" do
    describe "#initialize" do
      it "creates GemfileInfo object with correct gemfile lines" do
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

    describe ".build_gemfile_line" do
      describe "builds gemfile line" do
        it "based on gem_info data" do
          gemfile_line = "gem 'rails',require: false,github: 'https://github.com/rails/rails', '>= 6.0',"
          gem_info = described_class.gem_info(gemfile_line)
          built_line = described_class.build_gemfile_line(gem_info)
          expect(built_line).to eq("gem 'rails', '>= 6.0', require: false, github: 'https://github.com/rails/rails'")
        end

        it "making sure upper range is first element after gem name and lower range version, if an upper range exists" do
          TODO
        end
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
  end

  describe "rebuild gemfiles based on collected information" do

  end

end
