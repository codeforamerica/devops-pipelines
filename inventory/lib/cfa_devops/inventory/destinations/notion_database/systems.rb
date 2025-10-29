# frozen_string_literal: true

require_relative '../notion'

module CfaDevops
  module Inventory
    module Destinations
      module NotionDatabase
        # Notion database destination for systems inventory.
        class Systems < Notion
          private

          def data_source_id
            @config.notion.system_data_source_id
          end

          # @todo Lookup owners and admins in Notion users.
          def properties(item)
            props = {}
            props['Name'] = { title: [{ text: { content: item[:name] } }] }
            props['Type'] = { rich_text: [{ text: { content: item[:category] } }] } if item[:category]
            props['External System'] = { rich_text: [{ text: { content: item[:external_system] } }] }
            props['External ID'] = { rich_text: [{ text: { content: item[:external_id] } }] }

            props
          end
        end
      end
    end
  end
end
