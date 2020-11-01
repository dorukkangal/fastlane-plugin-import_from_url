require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class ImportFromUrlHelper
      # class methods that you define here become available in your action
      # as `Helper::ImportFromUrlHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the import_from_url plugin helper!")
      end
    end
  end
end
