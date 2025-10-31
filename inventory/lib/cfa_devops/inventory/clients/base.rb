# frozen_string_literal: true

module CfaDevops
  module Inventory
    module Clients
      # Base class for integration clients.
      class Base
        def initialize(config)
          @config = config
        end
      end
    end
  end
end
