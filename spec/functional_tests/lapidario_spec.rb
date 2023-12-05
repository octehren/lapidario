# frozen_string_literal: true

require_relative '../spec_helper'

SIMPLIFIED_GEM_AND_LOCKFILE_NAMES = "lapidario_v01"

SIMPLIFIED_FINAL_GEMFILE_FOR_COMPARISON = "lapidario_v01.hardcoded_from_lockfile"

RSpec.describe Lapidario do
  describe '.get_gemfile_and_lockfile_info' do
    context 'when project_path is provided in project_path_hash' do
      let(:project_path_hash) { { project_path: File.join(__dir__, "../fixtures/project_path_sample")  } }

      it 'returns GemfileInfo and LockfileInfo' do
        gemfile_info, lockfile_info = Lapidario.get_gemfile_and_lockfile_info(project_path_hash)
        expect(gemfile_info).to be_instance_of(Lapidario::GemfileInfo)
        expect(lockfile_info).to be_instance_of(Lapidario::LockfileInfo)
      end
    end

    context 'when gemfile_path and lockfile_path are provided in project_path_hash' do
      let(:project_path_hash) do
        {
          gemfile_path: get_random_gemfile_path,
          lockfile_path: get_random_lockfile_path 
        }
      end

      it 'returns GemfileInfo and LockfileInfo' do
        gemfile_info, lockfile_info = Lapidario.get_gemfile_and_lockfile_info(project_path_hash)
        expect(gemfile_info).to be_instance_of(Lapidario::GemfileInfo)
        expect(lockfile_info).to be_instance_of(Lapidario::LockfileInfo)
      end
    end

    context 'when neither project_path nor gemfile_path/lockfile_path is provided' do
      let(:project_path_hash) { {} }

      it 'raises an error' do
        expect { Lapidario.get_gemfile_and_lockfile_info(project_path_hash) }.to raise_error(Lapidario::Error)
      end
    end
  end

  describe '.hardcode_lockfile_versions_into_gemfile_info' do
    let(:gemfile_info) do
      Lapidario::GemfileInfo.new([
        'gem "rails", "6.0.0"',
        'gem "rspec", "3.10.0"'
      ])
    end

    let(:lockfile_info) do
      Lapidario::LockfileInfo.new([
        'GEM',
        'rails (6.0.0)',
        'rspec (3.10.0)',
        ''
      ])
    end

    it 'updates GemfileInfo with lockfile versions' do
      new_gemfile_info = Lapidario.hardcode_lockfile_versions_into_gemfile_info(gemfile_info, lockfile_info)
      expect(new_gemfile_info[0][:current_version]).to eq('6.0.0')
      expect(new_gemfile_info[1][:current_version]).to eq('3.10.0')
    end
  end

  describe '.build_new_gemfile' do
    let(:new_gemfile_info) do
      [
        { name: 'rails', current_version: '6.0.0', line_number: 0 },
        { name: 'rspec', current_version: '3.10.0', line_number: 1 }
      ]
    end

    let(:original_gemfile_lines) do
      [
        'gem "rails", "5.2.0"',
        'gem "rspec", "3.9.0"'
      ]
    end

    it 'builds a new Gemfile with updated versions' do
      new_gemfile = Lapidario.build_new_gemfile(new_gemfile_info, original_gemfile_lines)
      expect(new_gemfile[0]).to eq("gem 'rails', '6.0.0'")
      expect(new_gemfile[1]).to eq("gem 'rspec', '3.10.0'")
    end
  end

  describe '.save_gemfiles' do
    let(:save_path) { Dir.pwd }
    let(:original_gemfile) { ['gem "rails", "5.2.0"', 'gem "rspec", "3.9.0"'] }
    let(:new_gemfile) { ['gem "rails", "6.0.0"', 'gem "rspec", "3.10.0"'] }

    it 'saves original gemfile as backup and overwrites current Gemfile with new content' do
      Lapidario.save_gemfiles(save_path, new_gemfile, original_gemfile)

      expect(Lapidario::Helper).to have_received(:save_file).with(save_path + '/Gemfile.original', "gem \"rails\", \"5.2.0\"\ngem \"rspec\", \"3.9.0\"")
      expect(Lapidario::Helper).to have_received(:save_file).with(save_path + '/Gemfile', "gem \"rails\", \"6.0.0\"\ngem \"rspec\", \"3.10.0\"")
    end
  end

  describe 'everything comes together' do
    context 'using simple gemfile & gemfile.lock' do
      let(:input_gemfile_path) { get_gemfile_path(SIMPLIFIED_GEM_AND_LOCKFILE_NAMES) }
      let(:input_lockfile_path) { get_lockfile_path(SIMPLIFIED_GEM_AND_LOCKFILE_NAMES) }
      let(:input_project_params_hash) { get_final_gemfile_stringified(SIMPLIFIED_FINAL_GEMFILE_FOR_COMPARISON) }
      
      project_path_hash = { gemfile_path: input_gemfile_path, lockfile_path: input_lockfile_path }
      info_instances = Lapidario.get_gemfile_and_lockfile_info(project_path_hash)
      gemfile_info = info_instances[0]
      lockfile_info = info_instances[1]

      describe 'correctly produces a new gemfile' do
        it 'with same versions of lockfile' do
          
        end
      end
    end
  end
end
