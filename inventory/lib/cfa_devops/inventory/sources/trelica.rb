# frozen_string_literal: true

require 'base64'
require 'faraday'

require_relative 'base'
require_relative '../clients/trelica'
require_relative '../destinations/notion_database/systems'

module CfaDevops
  module Inventory
    module Sources
      # Trelica source for application inventory.
      class Trelica < Base
        ROLE_MAP = {
          'App owner' => :owner,
          'IT admin' => :admin
        }.freeze

        def self.name
          'Trelica'
        end

        def self.destination
          Destinations::NotionDatabase::Systems
        end

        def collect
          client.apps(filter: 'status eq "Managed"').map do |app|
            roles = collect_roles(app)
            {
              name: app[:name],
              status: app[:status],
              category: app[:mainCategory]&.[](:name),
              vendor: app[:vendor][:name],
              owners: roles[:owner] || [],
              admins: roles[:admin] || [],
              icon: app[:logoUrl],
              external_system: name,
              external_id: app[:id]
            }
          end
        end

        private

        # Create a client for the Trelica API.
        #
        # @return [Clients::Trelica] The Faraday connection object.
        def client
          @client = Clients::Trelica.new(@config)
        end

        def collect_roles(app)
          app.fetch(:roles, []).to_h do |role|
            unless ROLE_MAP.key?(role[:name])
              @config.logger.warn(
                "Trelica source: Unknown role '#{role[:name]}' for app '#{app[:name]}'"
              )
              next [nil, nil]
            end

            [ROLE_MAP[role[:name]], role[:members].map { |m| m[:name] }]
          end.compact
        end
      end
    end
  end
end
