require 'fastlane/action'
require_relative '../helper/import_from_url_helper'
require 'uri'
require 'open-uri'
require 'fileutils'

module Fastlane
  module Actions
    class ImportFromUrlAction < Action
      def self.run(params)
        url_address ||= params[:url]
        download_path ||= params[:path]
        file_name ||= params[:file_name]

        if valid_url(url_address)
          file_path = download_fast_file(url_address, download_path, file_name)
          # Fastlane::Actions::ImportAction.run(file_path)
          Fastlane::FastFile.new.import(file_path)
        else
          UI.user_error!("The url address #{url_address} is not valid.")
        end
      end

      def self.download_fast_file(url_address, download_path, file_name)
        puts("Downloading from #{url_address}")

        download_path = 'fastlane/.cache' if download_path.nil? || download_path.empty?
        file_name = 'DownloadedFastfile' if file_name.nil? || file_name.empty?

        Dir.mkdir(download_path) unless Dir.exist?(download_path)
        download_dir = Dir.open(download_path)
        file_path = File.join(Dir.pwd, download_dir.path, file_name)

        begin
          download = open(url_address)
          IO.copy_stream(download, file_path)
          file_path
        rescue => err
          UI.user_error!("An exception occurred while downloading Fastfile from #{url_address} -> #{err}")
          err
        end
      end

      def self.valid_url(url)
        if url.nil? || url.empty?
          false
        end

        begin
          uri = URI.parse(url)
          uri.host && uri.kind_of?(URI::HTTP)
        rescue URI::InvalidURIError
          false
        end
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: "IMPORT_FROM_URL",
                                       description: "The url address of the Fastfile to use its lanes",
                                       optional: false,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :file_name,
                                       env_name: "IMPORT_FROM_FILE_NAME",
                                       description: "The name of the file to be downloaded",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "IMPORT_FROM_FILE_NAME",
                                       description: "The path of the file to be downloaded",
                                       optional: true,
                                       type: String)
        ]
      end

      def self.description
        "Import another Fastfile from given url to use its lanes"
      end

      def self.authors
        ["Doruk Kangal"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "This is useful if you have shared lanes across multiple apps and you want to store a Fastfile in a url"
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end

      def self.example_code
        "import_from_url(
          url: '<the url of the Fastfile to be downloaded>', # Required and cannot be empty,
          path: '<the path of the Fastfile to be downloaded>', # Optional and default is fastlane/.cache
          file_name: '<the name of the Fastfile to be downloaded>' # Optional and default is DownloadedFastfile
        )"
      end
    end
  end
end
