# rubocop:disable Style/ClassAndModuleChildren
module PuppetX
  module PuppetLabs
    module DscLite
      # Hash formatter
      class PowerShellHashFormatter
        def self.format(dsc_value)
          if dsc_value.class.name == 'String'
            format_string(dsc_value)
          elsif dsc_value.class.ancestors.include?(Numeric)
            format_number(dsc_value)
          elsif [:true, :false].include?(dsc_value)
            format_boolean(dsc_value)
          elsif ['trueclass', 'falseclass'].include?(dsc_value.class.name.downcase)
            "$#{dsc_value}"
          elsif dsc_value.class.name == 'Array'
            format_array(dsc_value)
          elsif dsc_value.class.name == 'Hash'
            format_hash(dsc_value)
          elsif dsc_value.class.name == 'Puppet::Pops::Types::PSensitiveType::Sensitive'
            "'#{escape_quotes(dsc_value.unwrap)}' # PuppetSensitive"
          else
            raise "unsupported type #{dsc_value.class} of value '#{dsc_value}'"
          end
        end

        private_class_method
        def self.format_string(value)
          "'#{escape_quotes(value)}'"
        end

        private_class_method
        def self.format_number(value)
          value.to_s
        end

        private_class_method
        def self.format_boolean(value)
          "$#{value}"
        end

        private_class_method
        def self.format_array(value)
          '@(' + value.map { |m| format(m) }.join(', ') + ')'
        end

        private_class_method
        def self.format_hash(value)
          if !value.key?('dsc_type')
            format_hash_to_string(value)
          else
            case value['dsc_type']
            when 'MSFT_Credential'
              "([PSCustomObject]#{format_hash(value['dsc_properties'])} | new-pscredential)"
            else
              format_ciminstance(value)
            end
          end
        end

        private_class_method
        def self.format_hash_to_string(value)
          "@{\n" + value.map { |k, v| format(k) + ' = ' + format(v) }.join(";\n") + "\n" + '}'
        end

        private_class_method
        def self.format_ciminstance(value)
          type       = value['dsc_type'].gsub('[]', '')
          properties = [value['dsc_properties']].flatten

          output = properties.map do |p|
            "(New-CimInstance -ClassName '#{type}' -ClientOnly -Property #{format_hash_to_string(p)})"
          end

          if value['dsc_type'].end_with?('[]')
            output = output.join(",\n")
            "[CimInstance[]]@(\n" + output + "\n)"
          else
            "[CimInstance]#{output.first}"
          end
        end

        private_class_method
        def self.escape_quotes(text)
          text.gsub("'", "''")
        end
      end
    end
  end
end
