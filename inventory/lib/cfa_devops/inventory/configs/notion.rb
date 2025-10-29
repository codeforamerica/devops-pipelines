# frozen_string_literal: true

require 'configsl'

module CfaDevops
  module Inventory
    module Configs
      # Configuration for the Notion integration.
      class Notion < ConfigSL::Config
        option :api_token, type: String, required: true, env_variable: 'NOTION_API_TOKEN'
        option :system_data_source_id, type: String, required: true, env_variable: 'NOTION_SYSTEM_DATA_SOURCE_ID'
      end
    end
  end
end
