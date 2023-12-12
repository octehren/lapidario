# spec/lapidario/Lapidario::Helper_spec.rb

require_relative "../spec_helper"

RSpec.describe Lapidario::Helper do

  let(:gemfile_path) { -> { get_random_gemfile_path }.call }
  let(:lockfile_path) { -> { get_random_lockfile_path }.call }


  describe "#version_fragment?" do
    it "returns true for valid version fragments" do
      expect(Lapidario::Helper.version_fragment?('~> 1.2')).to be(true)
      expect(Lapidario::Helper.version_fragment?('>= 10.2.1')).to be(true)
      expect(Lapidario::Helper.version_fragment?('<= 10.2.1')).to be(true)
      expect(Lapidario::Helper.version_fragment?('1.2')).to be(true)
      expect(Lapidario::Helper.version_fragment?('>1.2')).to be(true) # no whitespace between version and sign
      expect(Lapidario::Helper.version_fragment?('< 1.2')).to be(true)
      expect(Lapidario::Helper.version_fragment?('> 1.2')).to be(true)
      expect(Lapidario::Helper.version_fragment?('1.2.alpha')).to be(true)
      expect(Lapidario::Helper.version_fragment?('2.0.beta3')).to be(true)
      expect(Lapidario::Helper.version_fragment?('= 2.0.beta3')).to be(false)
      expect(Lapidario::Helper.version_fragment?('== 1.1')).to be(false)
    end

    it "returns false for invalid version fragments" do
      expect(Lapidario::Helper.version_fragment?('invalid_version')).to be(false)
      expect(Lapidario::Helper.version_fragment?('')).to be(false)
    end
  end

  describe "#gem_line?" do
    it "returns true for lines starting with 'gem '" do
      expect(Lapidario::Helper.gem_line?('gem "example", "~> 1.2"')).to be(true)
    end

    it "returns true for lines starting with 'gem ' prepended by one or more whitespaces" do
      expect(Lapidario::Helper.gem_line?('  gem "example", "~> 1.2"')).to be(true)
    end

    it "returns false for lines not starting with 'gem '" do
      expect(Lapidario::Helper.gem_line?('diamond "example", "~> 1.2"')).to be(false)
      expect(Lapidario::Helper.gem_line?('other_line')).to be(false)
    end

    it "returns false for lines ending in # LOCK" do
      expect(Lapidario::Helper.gem_line?('gem "example", "~> 1.2" # LOCK')).to be(false)
      expect(Lapidario::Helper.gem_line?('gem "example", "~> 1.2" #LOCK')).to be(false)
      expect(Lapidario::Helper.gem_line?('gem "example", "~> 1.2" #     LOCK')).to be(false)
      expect(Lapidario::Helper.gem_line?('gem "example", "~> 1.2" # LOCKED? NOT!')).to be(true)
    end
  end

  describe "#get_file_as_array_of_lines" do
    it "returns an array of lines from a file" do
      file_path = rand.round ? gemfile_path : lockfile_path
      lines_array = Lapidario::Helper.get_file_as_array_of_lines(file_path)
      expect(lines_array).to be_an(Array)
      # Add more expectations for the content of lines_array
    end
  end

  describe "#slice_up_to_next_empty_line" do
    it "returns a slice of lines up to the next empty line" do
      lines_array = [
        'line 1',
        'line 2',
        '',
        'line 4'
      ]
      sliced_lines = Lapidario::Helper.slice_up_to_next_empty_line(0, lines_array)
      expect(sliced_lines).to eq(['line 1', 'line 2'])
    end
  end

  describe "#primary_gem_line?" do
    it "returns true for primary gem lines" do
      expect(Lapidario::Helper.lockfile_primary_gem_line?('    diff-lcs (1.5.0)')).to be(true)
    end

    it "returns false for non-primary gem lines" do
      expect(Lapidario::Helper.lockfile_primary_gem_line?('      ast (~> 2.4.1)')).to be(false)
      expect(Lapidario::Helper.lockfile_primary_gem_line?('ast (~> 2.4.1)')).to be(false)
    end
  end

  describe '.format_path' do
    context 'when formatting a regular file path' do
      it 'returns the path with Gemfile appended' do
        filepath = './project/'
        result = Lapidario::Helper.format_path(filepath)
        expect(result).to eq('./project/Gemfile')
      end

      it 'returns the path with Gemfile.lock appended' do
        filepath = './project/'
        result = Lapidario::Helper.format_path(filepath, true)
        expect(result).to eq('./project/Gemfile.lock')
      end

      it 'returns the original path if it already has Gemfile appended' do
        filepath = './project/Gemfile'
        result = Lapidario::Helper.format_path(filepath)
        expect(result).to eq('./project/Gemfile')
      end

      it 'returns the original path if it already has Gemfile.lock appended' do
        filepath = './project/Gemfile.lock'
        result = Lapidario::Helper.format_path(filepath, true)
        expect(result).to eq('./project/Gemfile.lock')
      end
    end

    context 'when formatting a path ending with "/"' do
      it 'appends Gemfile' do
        filepath = './project/'
        result = Lapidario::Helper.format_path(filepath)
        expect(result).to eq('./project/Gemfile')
      end

      it 'appends Gemfile.lock' do
        filepath = './project/'
        result = Lapidario::Helper.format_path(filepath, true)
        expect(result).to eq('./project/Gemfile.lock')
      end
    end

    context 'when formatting a path without a trailing slash' do
      it 'appends Gemfile' do
        filepath = './project'
        result = Lapidario::Helper.format_path(filepath)
        expect(result).to eq('./project/Gemfile')
      end

      it 'appends Gemfile.lock' do
        filepath = './project'
        result = Lapidario::Helper.format_path(filepath, true)
        expect(result).to eq('./project/Gemfile.lock')
      end
    end
  end

  describe '.extract_git_gem_info' do
    let(:git_gem_fragment) do
      [
        "GIT",
        "  remote: https://github.com/mastodon/rails-settings-cached.git",
        "  revision: 86328ef0bd04ce21cc0504ff5e334591e8c2ccab",
        "  branch: v0.6.6-aliases-true",
        "  specs:",
        "    rails-settings-cached (0.6.6)",
        "      rails (>= 4.2.0)"
      ]
    end

    subject { Lapidario::Helper.extract_git_gem_info(git_gem_fragment) }

    it 'extracts the gem name correctly' do
      expect(subject.first).to eq('rails-settings-cached')
    end

    it 'extracts the gem version and remote URL correctly' do
      expect(subject.last).to eq("'0.6.6', git: 'https://github.com/mastodon/rails-settings-cached.git'")
    end
  end
  
end