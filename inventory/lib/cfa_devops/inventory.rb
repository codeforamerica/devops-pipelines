# frozen_string_literal: true

require_relative 'inventory/version'
require_relative 'inventory/config'
require_relative 'inventory/sources'

module CfaDevops
  # Inventory management system for DevOps resources.
  module Inventory
    @mutex = Mutex.new

    # Set or load the system configuration.
    #
    # If no configuration is explicitly set, it will be loaded from the
    # environment.
    #
    # @param config [Config] Configuration to set for the system.
    def self.config(config = nil)
      @mutex.synchronize do
        if config
          @config = config
        else
          @config ||= Config.from_environment
        end
      end
    end

    # Collect inventory from all systems, but don't upload them.
    def self.collect
      Sources.sources.to_h do |source|
        inventory = source.new(config).collect
        config.logger.debug("Collected #{inventory.size} items from #{source.name}")

        yield source, inventory if block_given?

        [source.name, inventory]
      rescue StandardError => e
        handle_exception(source, e)
      end
    end

    # Collect inventory from all systems and sync them with their destinations.
    def self.run
      collect do |source, inventory|
        sync_inventory(source, inventory)
      end
    end

    # Sync an inventory with its destination.
    #
    # @param source [Sources::Base] The source the inventory is from.
    # @param inventory [Array<Hash>] The inventory data to sync.
    private_class_method def self.sync_inventory(source, inventory)
      config.logger.debug("Syncing inventory for #{source.name} with Notion")
      source.destination.new(config).write(inventory)
    end

    # Handle exceptions that occur during inventory collection.
    #
    # @param source [Sources::Source] The source that was being processed.
    # @param error [StandardError] The error that occurred.
    # @return [Array] Valid promise repose representing a failure.
    private_class_method def self.handle_exception(source, error)
      config.logger.error("An error occurred: #{error.message}")
      [source.name, false]
    end
  end
end
