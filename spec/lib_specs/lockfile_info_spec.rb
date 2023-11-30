# lockfile_info_spec.rb

require_relative "../spec_helper"
SIMPLE_LOCKFILE_PATH = "lapidario_v01"
RSpec.describe Lapidario::LockfileInfo do
  describe "using simple lockfile" do
    let(:lockfile_as_array_of_strings) { get_lockfile_path(SIMPLE_LOCKFILE_PATH) }
    let(:lockfile_info) { described_class.new(lockfile_as_strings) }

    describe '#initialize' do
      it 'initializes with Rubygems gems and empty git gems' do
        expect(lockfile_info.instance_variable_get(:@rubygems_gems)).to eq('rails' => '5.2.3', 'rspec' => '3.10.0')
        expect(lockfile_info.instance_variable_get(:@git_gems)).to eq([])
      end
    end

    describe '#puts_versionless_rubygems_info' do
      it 'puts versionless Rubygems information' do
        expect { lockfile_info.puts_versionless_rubygems_info }.to output(
          /rails.*5.2.3.*rspec.*3.10.0.*There are 0 gems without specified version/
        ).to_stdout
      end

      it 'puts versionless Rubygems information for gems without versions' do
        gemfile_lock_as_strings << "  gem 'shoulda-matchers'"
        lockfile_info_with_nil_versions = described_class.new(gemfile_lock_as_strings)

        expect { lockfile_info_with_nil_versions.puts_versionless_rubygems_info }.to output(
          /shoulda-matchers.*nil.*There are 1 gems without specified version/
        ).to_stdout
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
          "  gem 'rails', '5.2.3'",
          "  gem 'rspec', '3.10.0'",
          "  gem 'shoulda-matchers'",
          ""
        ]

        result = described_class.get_rubygems_from_gemfile_lock(gemfile_lock_as_strings)

        expect(result).to eq('rails' => '5.2.3', 'rspec' => '3.10.0', 'shoulda-matchers' => nil)
      end
    end

    describe '.get_git_gems_from_gemfile_lock' do
      it 'puts TODO message' do
        expect { described_class.get_git_gems_from_gemfile_lock([]) }.to output(/TODO/).to_stdout
      end
    end
  end
end