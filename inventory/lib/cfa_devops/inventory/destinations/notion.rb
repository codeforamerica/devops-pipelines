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
        # @return [Boolean] Whether all items were written successfully.
        def write(inventory)
          return nil if inventory.nil? || inventory.empty?

          inventory.map do |item|
            upsert_item(item)
            true
          rescue StandardError => e
            @config.logger.error("Failed to sync inventory item #{item[:name]}: #{e.message}")
            false
          end.all?(true)
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
          client.create_page(parent_id: data_source_id, properties: properties(item),
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
        # This method queries the Notion API to find an existing entry in the
        # data source that matches the given item's name.
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

        # Resolve a list of email addresses to Notion user IDs.
        #
        # @param emails [Array<String>] The list of email addresses.
        # @return [Array<Hash>] The list of Notion user ID hashes suitable for
        #   use with the Notion API.
        def resolve_people(emails)
          emails.filter_map do |email|
            { id: @client.user_id_by_email(email:) }
          rescue Clients::Notion::UserNotFoundError
            @config.logger.warn("Unable to find Notion user for email: #{email}")
          end
        end
      end
    end
  end
end
