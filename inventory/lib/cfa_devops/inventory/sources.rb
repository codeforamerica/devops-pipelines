# frozen_string_literal: true

require_relative 'sources/trelica'

module CfaDevops
  module Inventory
    # Module for inventory sources.
    module Sources
      # Find all source classes.
      #
      # @return [Array<Class>] An array of source classes.
      def self.sources
        sources_for_namespace(self)
      end

      # Find all source classes in a given namespace.
      #
      # This method will recursively search through the constants of the given
      # namespace and collect all classes that have a `collect` method defined.
      #
      # @param namespace [Module] The namespace to search for source classes.
      # @return [Array<Class>] An array of source classes found in the namespace.
      private_class_method def self.sources_for_namespace(namespace)
        namespace.constants.each_with_object([]) do |const_name, collectors|
          const = namespace.const_get(const_name)
          if const.is_a?(Class) && const.method_defined?(:collect)
            collectors << const
          elsif const.is_a?(Module)
            collectors.concat(sources_for_namespace(const))
          end
        end
      end
    end
  end
end
