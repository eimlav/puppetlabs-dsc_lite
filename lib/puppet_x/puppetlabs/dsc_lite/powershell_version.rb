# rubocop:disable Style/ClassAndModuleChildren
module PuppetX
  module PuppetLabs
    module DscLite
      # Gets the Powershell version
      class PowerShellVersion
      end
    end
  end
end

if Puppet::Util::Platform.windows?
  require 'win32/registry'
  module PuppetX
    module PuppetLabs
      module DscLite
        # Gets the Powershell version
        class PowerShellVersion
          ACCESS_TYPE = Win32::Registry::KEY_READ | 0x100
          HKLM              = Win32::Registry::HKEY_LOCAL_MACHINE
          PS_ONE_REG_PATH   = 'SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine'.freeze
          PS_THREE_REG_PATH = 'SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine'.freeze
          REG_KEY           = 'PowerShellVersion'.freeze

          def self.version
            powershell_three_version || powershell_one_version
          end

          def self.powershell_one_version
            version = nil
            begin
              HKLM.open(PS_ONE_REG_PATH, ACCESS_TYPE) do |reg|
                version = reg[REG_KEY]
              end
            rescue
              version = nil
            end
            version
          end

          def self.powershell_three_version
            version = nil
            begin
              HKLM.open(PS_THREE_REG_PATH, ACCESS_TYPE) do |reg|
                version = reg[REG_KEY]
              end
            rescue
              version = nil
            end
            version
          end
        end
      end
    end
  end
end
