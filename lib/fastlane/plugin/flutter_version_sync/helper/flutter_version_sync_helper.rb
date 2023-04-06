require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class FlutterVersionSyncHelper
      # class methods that you define here become available in your action
      # as `Helper::FlutterVersionSyncHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the flutter_version_sync plugin helper!")
      end
    end
  end
end
