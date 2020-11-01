require 'fastlane/action'
require 'uri'
require 'open-uri'
require 'fileutils'
require_relative '../helper/import_from_url_helper'

module Fastlane
  module Actions
    class ImportFromUrlAction < Action
      attr_reader :url_address, :download_path, :file_name, :file_path

      class << self
        def run(params)
          new(params).import
        end

        def available_options
          [
            FastlaneCore::ConfigItem.new(
              key: :url,
              env_name: "IMPORT_FROM_URL",
              description: "The url address of the Fastfile to use its lanes",
              optional: false,
              type: String
            ),

            FastlaneCore::ConfigItem.new(
              key: :file_name,
              env_name: "IMPORT_FROM_FILE_NAME",
              description: "The name of the file to be downloaded",
              optional: true,
              type: String
            ),

            FastlaneCore::ConfigItem.new(
              key: :path,
              env_name: "IMPORT_FROM_FILE_NAME",
              description: "The path of the file to be downloaded",
              optional: true,
              type: String
            )
          ]
        end

        def authors
          ["Doruk Kangal"]
        end

        def description
          "Import another Fastfile from given url to use its lanes"
        end

        def details
          "This is useful if you have shared lanes across multiple apps and you want to store a Fastfile in a url"
        end

        def example_code
          "import_from_url(
          url: '<the url of the Fastfile to be downloaded>', # Required and cannot be empty,
          path: '<the path of the Fastfile to be downloaded>', # Optional and default is fastlane/.cache
          file_name: '<the name of the Fastfile to be downloaded>' # Optional and default is DownloadedFastfile
        )"
        end
      end

      def initialize(params)
        @url_address = params[:url]
        @download_path = params[:path]
        @file_name = params[:file_name]
      end

      def import
        return UI.user_error!("The url address #{url_address} is not valid.") unless url_valid?

        download_fast_file
        import_to_fastlane
      end

      private

      def import_to_fastlane
        Fastlane::FastFile.new.import(file_path)
      end

      def download_fast_file
        puts("Downloading from #{url_address}")

        download_path ||= 'fastlane/.cache'
        file_name ||= 'DownloadedFastfile'

        Dir.mkdir(download_path) unless Dir.exist?(download_path)
        download_dir = Dir.open(download_path)
        @file_path = File.join(Dir.pwd, download_dir.path, file_name)

        begin
          download = open(url_address)
          IO.copy_stream(download, file_path)
        rescue => err
          UI.user_error!("An exception occurred while downloading Fastfile from #{url_address} -> #{err}")
          err
        end
      end

      def url_valid?
        return false if url_address.nil?

        begin
          uri = URI.parse(url_address)
          uri.host && uri.kind_of?(URI::HTTP)
        rescue URI::InvalidURIError
          false
        end
      end
    end
  end
end
