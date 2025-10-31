# frozen_string_literal: true

module CfaDevops
  module Inventory
    module Destinations
      # Base class for inventory destinations.
      #
      # @abstract Subclasses must implement the `write` method.
      class Base
        def initialize(config)
          @config = config
        end

        def write(inventory)
          raise NotImplementedError, 'Subclasses must implement the write method'
        end
      end
    end
  end
end
