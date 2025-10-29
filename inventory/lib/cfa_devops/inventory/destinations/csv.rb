# frozen_string_literal: true

require 'csv'

require_relative 'base'

module CfaDevops
  module Inventory
    module Destinations
      # CSV destination for inventory output.
      class CSV < Base
        # Write the inventory to a CSV file.
        #
        # @param filename [String] Filename to write inventory to.
        # @param inventory [Array] Inventory items to write to the file.
        def write(filename, inventory)
          return nil if inventory.nil? || inventory.empty?

          ::CSV.open(filename, 'wb') do |csv|
            # Use the keys of the first item as the header row.
            csv << inventory.first.keys.map(&:to_s)

            inventory.each do |item|
              csv << item.values.map do |v|
                v.is_a?(Array) ? v.join("\n") : v
              end
            end
          end
        end
      end
    end
  end
end
