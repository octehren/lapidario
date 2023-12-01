# lockfile_info_spec.rb

require_relative "../spec_helper"

SIMPLE_LOCKFILE_PATH = "simplified"

RSpec.describe Lapidario::LockfileInfo do
  describe "using simple lockfile" do
    let(:lockfile_as_array_of_strings) { Lapidario::Helper.get_file_as_array_of_lines(get_lockfile_path(SIMPLE_LOCKFILE_PATH)) }
    let(:lockfile_info) { described_class.new(lockfile_as_array_of_strings) }

    describe '#initialize' do
      it 'initializes with Rubygems gems and empty git gems' do
        expect(lockfile_info.instance_variable_get(:@rubygems_gems)).to eq({"ast"=>"2.4.2", "coderay"=>"1.1.3", "diff-lcs"=>"1.5.0", "json"=>"2.6.3", "language_server-protocol"=>"3.17.0.3", "rubocop-ast"=>"1.30.0", "ruby-progressbar"=>"1.13.0", "unicode-display_width"=>"2.5.0"})
        expect(lockfile_info.instance_variable_get(:@git_gems)).to eq([])
      end
    end

    describe '#puts_versionless_rubygems_info' do
      it 'puts versionless Rubygems information when there are 0 versionless gems' do
        expect { lockfile_info.puts_versionless_rubygems_info }.to output(
          /There are 0 gems without specified version/
        ).to_stdout
      end

      it 'puts versionless Rubygems information for gems without versions' do
        lockfile_as_array_of_strings << "    shoulda-matchers"
        lockfile_as_array_of_strings << "    ruby-progressbar"
        lockfile_info_with_nil_versions = described_class.new(lockfile_as_array_of_strings)

        expect { lockfile_info_with_nil_versions.puts_versionless_rubygems_info }.to output("ruby-progressbar\n\nshoulda-matchers\n\nThere are 2 gems without specified version, names are listed above.").to_stdout
      end
    end

    describe '#git_gems?' do
      it 'complete later' do
        TODO
      end
    end

    describe '.get_rubygems_from_gemfile_lock' do
      it 'returns a hash of rubygems gems' do
        gemfile_lock_as_strings = [
          "GEM",
          "    ast (2.4.2)",
          "    rubocop (1.57.2)",
          "    rspec (3.12.0)",
          ""
        ]

        result = described_class.get_rubygems_from_gemfile_lock(gemfile_lock_as_strings)

        expect(result).to eq('ast' => '2.4.2', 'rubocop' => '1.57.2', 'rspec' => '3.12.0',)
      end
    end

    describe '.get_git_gems_from_gemfile_lock' do
      it 'puts TODO message' do
        expect { described_class.get_git_gems_from_gemfile_lock([]) }.to output(/TODO/).to_stdout
      end
    end
  end
end