require 'cfpropertylist'

module QMA
  module Parser
    ##
    # 解析 mobileprovision 文件
    class MobileProvision
      def initialize(path)
        @path = path
      end

      def name
        mobileprovision.try(:[], 'Name')
      end

      def app_name
        mobileprovision.try(:[], 'AppIDName')
      end

      def devices
        mobileprovision.try(:[], 'ProvisionedDevices')
      end

      def team_identifier
        mobileprovision.try(:[], 'TeamIdentifier')
      end

      def team_name
        mobileprovision.try(:[], 'TeamName')
      end

      def profile_name
        mobileprovision.try(:[], 'Name')
      end

      def created_date
        mobileprovision.try(:[], 'CreationDate')
      end

      def expired_date
        mobileprovision.try(:[], 'ExpirationDate')
      end

      def entitlements
        mobileprovision.try(:[], 'Entitlements')
      end

      def mobileprovision
        data = `security cms -D -i "#{@path}"`
        begin
          @mobileprovision = CFPropertyList.native_types(CFPropertyList::List.new(data: data).value)
        rescue CFFormatError
          @mobileprovision = nil
        end
      end
    end
  end
end
