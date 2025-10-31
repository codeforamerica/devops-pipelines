# frozen_string_literal: true

require 'configsl'

require_relative 'configs/notion'
require_relative 'configs/trelica'

module CfaDevops
  module Inventory
    # Inventory system configuration.
    class Config < ConfigSL::Config
      option :notion, type: Configs::Notion, required: true
      option :trelica, type: Configs::Trelica, required: true

      option :log_level, type: String, enum: %w[debug info warn error fatal],
                         default: 'info'

      def logger
        @logger ||= Logger.new($stdout, level: log_level)
      end

      def self.from_environment
        params = options.transform_values do |opts|
          if opts[:type] <= ConfigSL::Config
            opts[:type].from_environment
          else
            ENV.fetch(opts[:env_variable], opts[:default])
          end
        end

        new(params)
      end
    end
  end
end
