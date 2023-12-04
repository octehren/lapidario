# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Lapidario do
  describe '.get_gemfile_and_lockfile_info' do
    context 'when project_path is provided in project_path_hash' do
      let(:project_path_hash) { { 
        project_path: '', 
        gemfile_path: get_random_gemfile_path,
        lockfile_path: get_random_lockfile_path  } }

      it 'returns GemfileInfo and LockfileInfo' do
        gemfile_info, lockfile_info = Lapidario.get_gemfile_and_lockfile_info(project_path_hash)
        expect(gemfile_info).to be_instance_of(Lapidario::GemfileInfo)
        expect(lockfile_info).to be_instance_of(Lapidario::LockfileInfo)
      end
    end

    context 'when gemfile_path and lockfile_path are provided in project_path_hash' do
      let(:project_path_hash) do
        {
          gemfile_path: '/path/to/Gemfile',
          lockfile_path: '/path/to/Gemfile.lock'
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
        'rails (6.0.0)',
        'rspec (3.10.0)'
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
      expect(new_gemfile[0]).to eq('gem "rails", "6.0.0"')
      expect(new_gemfile[1]).to eq('gem "rspec", "3.10.0"')
    end
  end
end
