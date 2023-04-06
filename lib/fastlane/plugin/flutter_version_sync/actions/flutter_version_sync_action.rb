require 'fastlane/action'
require 'yaml'
require 'fileutils'
require_relative '../helper/flutter_version_sync_helper'

module Fastlane
  module Actions
    class FlutterVersionSyncAction < Action
      def self.run(params)
        pubspec_location = params[:pubspec_location]        
        UI.message("The flutter_version_sync is running in #{Dir.getwd}, with #{pubspec_location}")
        yaml = YAML.load_file(pubspec_location)
        version, build_number = yaml['version'].split('+')
        UI.message("The flutter_version_sync is found version #{version} and build #{build_number}")
        
        new_build_number = build_number.to_i + 1
        version_info = version.split(".").map(&:to_i)
        new_version = ""

        case params[:bump]
        when "patch"
          version_info[2] += 1
        when "minor"
          version_info[1] += 1
          version_info[2] = 0
        when "major"
          version_info[0] += 1
          version_info[1] = 0
          version_info[1] = 0          
        end
        new_version = version_info.join(".")
        UI.message("The flutter_version_sync is bumped to version #{new_version} and build #{new_build_number}")

        pubspec_contents = File.read(pubspec_location)
        new_pubspec_yaml = pubspec_contents.gsub(/version: [0-9]*\.[0-9]*\.[0-9]*\+[0-9]*/, "version: #{new_version}+#{new_build_number}")
        File.open(pubspec_location, "w") {|file| file.puts new_pubspec_yaml } 

        
        Dir.glob("**/app/build.gradle") do |path|
          UI.message(" -> Found a build.gradle file at path: (#{path})!")
          
          gradle_contents = File.read(path)
          new_gradle_w_version_name = gradle_contents.gsub(/versionName\s"[0-9]*\.[0-9]*\.[0-9]*"/, "versionName \"#{new_version}\"")
          new_gradle = new_gradle_w_version_name.gsub(/versionCode\s[0-9]*/, "versionCode #{new_build_number}")
          File.open(path, "w") {|file| file.puts new_gradle } 
        end

        {
          'version_info' => new_version,
          'build_number' => new_build_number
        }
      end

      def self.description
        "Keep versions syncronized from pubspec.yml to gradle"
      end

      def self.authors
        ["Mikko Levonmaa"]
      end

      def self.return_value
        [
          ['VERSION_INFO', 'The version info x.y.x to which pubspec and gradle was updated to'],
          ['BUILD_NUMBER', 'The build number info X to which pubspec and gradle was updated to']
        ]
      end

      def self.details
        "The pubspec.yml is the master nad it will be incremented and synced to grandle and Info.plist"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :pubspec_location,
            env_name: 'SYNCVERSION_PUBSPEC_LOCATION',
            description: 'The location of pubspec.yml',
            optional: true,
            type: String,
            default_value: '../pubspec.yaml'
          ),
          FastlaneCore::ConfigItem.new(
            key: :bump,
            env_name: "SYNCVERSION_BUMP_TYPE",
            description: "The type of this version bump. Available: patch, minor, major",
            optional: false,            
            verify_block: proc do |value|
              UI.user_error!("Available values are 'patch', 'minor' and 'major'") unless ['patch', 'minor', 'major'].include?(value)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :patch,
            env_name: 'PATCH',
            description: 'Increment the patch version',
            optional: true,
            type: Boolean,
            default_value: true
          ),          
        ]
      end

      def self.is_supported?(platform)        
        [:ios, :mac, :android].include?(:android)      
      end
    end
  end
end
