# rubocop:disable RSpec/FilePath
# rubocop:disable RSpec/AnyInstance
# ! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/type'
require 'puppet_x/puppetlabs/dsc_lite/powershell_version'

describe PuppetX::PuppetLabs::DscLite::PowerShellVersion do
  let(:ps) do
    described_class
  end

  before :each do
    skip 'Not on Windows platform' unless Puppet::Util::Platform.windows?
  end

  describe 'when powershell is installed' do
    describe 'when powershell version is greater than three' do
      it 'detects a powershell version' do
        Win32::Registry.any_instance.expects(:[]).with('PowerShellVersion').returns('5.0.10514.6')

        version = ps.version

        expect(version).to eq '5.0.10514.6'
      end

      it 'calls the powershell three registry path' do
        reg_key = mock('bob')
        reg_key.expects(:[]).with('PowerShellVersion').returns('5.0.10514.6')
        Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).yields(reg_key).once

        ps.version
      end

      it 'does not call powershell one registry path' do
        reg_key = mock('bob')
        reg_key.expects(:[]).with('PowerShellVersion').returns('5.0.10514.6')
        Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).yields(reg_key)
        Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).times(0)

        ps.version
      end
    end

    describe 'when powershell version is less than three' do
      it 'detects a powershell version' do
        Win32::Registry.any_instance.expects(:[]).with('PowerShellVersion').returns('2.0')

        version = ps.version

        expect(version).to eq '2.0'
      end

      it 'calls powershell one registry path' do
        reg_key = mock('bob')
        reg_key.expects(:[]).with('PowerShellVersion').returns('2.0')
        Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).raises(Win32::Registry::Error.new(2), 'nope').once
        Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).yields(reg_key).once

        version = ps.version

        expect(version).to eq '2.0'
      end
    end
  end

  describe 'when powershell is not installed' do
    it 'returns nil and not throw' do
      # reg_key = mock('bob')
      # reg_key.expects(:[]).with('PowerShellVersion').returns('2.0')
      Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).raises(Win32::Registry::Error.new(2), 'nope').once
      Win32::Registry.any_instance.expects(:open).with('SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine', Win32::Registry::KEY_READ | 0x100).raises(Win32::Registry::Error.new(2), 'nope').once

      version = ps.version

      expect(version).to eq nil
    end
  end
end
