# frozen_string_literal: true

require 'rails/generators'

module OnofficeSdk
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Creates an initializer for OnOfficeSDK and an optional service class'

      class_option :service, type: :boolean, default: true, desc: 'Generate a simple service class using the SDK'

      def create_initializer
        template 'initializer.rb', 'config/initializers/onoffice_sdk.rb'
      end

      def create_service
        return unless options[:service]

        template 'service.rb', 'app/services/onoffice_client.rb'
      end
    end
  end
end
