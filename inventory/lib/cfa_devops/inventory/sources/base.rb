# frozen_string_literal: true

module CfaDevops
  module Inventory
    module Sources
      # Base class for inventory sources.
      #
      # @abstract Subclasses must implement the `collect`, `destination` and
      #   `name` class methods.
      class Base
        # Initialize a new source.
        #
        # @param config [Config] The configuration for the source.
        def initialize(config)
          @config = config
        end

        # Destination class for the source.
        #
        # @return [Class] The destination class.
        def destination
          self.class.destination
        end

        # Name of the source.
        #
        # @return [String] The name of the source.
        def name
          self.class.name
        end

        # Destination class for the source.
        #
        # @return [Class] The destination class.
        # @abstract Subclasses must implement this method.
        def self.destination
          raise NotImplementedError, 'Subclasses must implement the destination method'
        end

        # Name of the source.
        #
        # @return [String] The name of the source.
        # @abstract Subclasses must implement this method.
        def self.name
          raise NotImplementedError, 'Subclasses must implement the name method'
        end
      end
    end
  end
end
