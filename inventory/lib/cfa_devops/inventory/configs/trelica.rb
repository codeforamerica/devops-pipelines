# frozen_string_literal: true

require 'base64'
require 'configsl'

module CfaDevops
  module Inventory
    module Configs
      # Configuration for the Trelica integration.
      class Trelica < ConfigSL::Config
        option :client_id, type: String, required: true, env_variable: 'TRELICA_CLIENT_ID'
        option :client_secret, type: String, required: true, env_variable: 'TRELICA_CLIENT_SECRET'

        def basic_auth_header
          "Basic #{Base64.strict_encode64("#{client_id}:#{client_secret}")}"
        end
      end
    end
  end
end
