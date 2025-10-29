# frozen_string_literal: true

require_relative 'base'
require_relative '../clients/notion'

module CfaDevops
  module Inventory
    module Destinations
      # Notion destination for inventory output.
      #
      # @abstract Subclasses must implement the `data_source_id` and
      #   `properties` methods.
      class Notion < Base
        # Write the inventory to Notion
        #
        # @param inventory [Array<Hash>] The inventory data to write.
        def write(inventory)
          return nil if inventory.nil? || inventory.empty?

          inventory.each do |item|
            upsert_item(item)
          end
        end

        private

        # Upsert an inventory item into Notion.
        #
        # @param item [Hash] The inventory item.
        def upsert_item(item)
          entry = entry_for_item(item)
          entry ? update_item(item, entry) : create_item(item)
        end

        # Create a new entry for an inventory item.
        #
        # @param item [Hash] The inventory item.
        def create_item(item)
          @config.logger.debug("Creating entry for #{item[:name]}")
          client.create_page(parent_id: ENV.fetch('NOTION_DATASOURCE_ID', nil), properties: properties(item),
                             icon: icon(item))
        end

        # Update an existing entry for an inventory item.
        #
        # @param item [Hash] The inventory item.
        # @param entry [Hash] The existing entry to update.
        def update_item(item, entry)
          @config.logger.debug("Updating entry #{entry[:id]} for #{item[:name]}")
          client.update_page(id: entry[:id], properties: properties(item), icon: icon(item))
        end

        # ID of the Notion data source of the destination.
        #
        # @return [String] The Notion data source ID.
        # @abstract Subclasses must implement this method.
        def data_source_id
          raise NotImplementedError, 'Subclasses must implement data_source_id method'
        end

        # Notion client for interacting with the Notion API.
        #
        # @return [Clients::Notion] The Notion client.
        def client
          @client = Clients::Notion.new(@config)
        end

        # Look up an existing entry for an inventory item.
        #
        # @param item [Hash] The inventory item.
        # @return [Hash, nil] The existing entry or nil if not found.
        def entry_for_item(item)
          client.data_source_entry_by_name(id: data_source_id, name: item[:name])
        end

        # Set icon for an item if available.
        #
        # @param item [Hash] The inventory item.
        # @return [Hash, nil] The icon data or nil if no icon is set.
        def icon(item)
          return nil unless item[:icon]

          { type: 'external', external: { url: item[:icon] } }
        end

        # Build the properties for the Notion page.
        #
        # @param item [Hash] The inventory item.
        # @return [Hash] The properties hash for Notion.
        # @abstract Subclasses must implement this method.
        def properties(item)
          raise NotImplementedError, 'Subclasses must implement properties method'
        end
      end
    end
  end
end
