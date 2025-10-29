# frozen_string_literal: true

require_relative 'base'

module CfaDevops
  module Inventory
    module Clients
      # Client for interacting with the Trelica API.
      class Trelica < Base
        DEFAULT_RESULTS_PER_PAGE = 100

        # Retrieve a list of applications from Trelica.
        #
        # @param filter [String, nil] Optional filter to apply to the
        #   applications.
        # @return [Array<Hash>] List of applications.
        def apps(filter: nil)
          response = get('/api/apps/v1', { filter:, limit: DEFAULT_RESULTS_PER_PAGE })
          apps = response.body[:results]

          while response.body[:next]
            response = get(response.body[:next])
            apps.concat(response.body[:results])
          end

          apps
        end

        # Perform a GET request to the Trelica API.
        #
        # @param url [String] The API endpoint URL.
        # @param params [Hash, nil] Optional query parameters.
        # @param headers [Hash] Optional additional headers.
        def get(url, params = nil, headers = {})
          conn.get(url, params, request_headers.merge(headers))
        end

        private

        # Establish a connection to the Trelica API.
        #
        # @return [Faraday::Connection] The Faraday connection object.
        def conn
          @conn = Faraday.new 'https://app.trelica.com' do |conn|
            conn.request :json
            conn.response :json, parser_options: { symbolize_names: true }
            conn.response :raise_error
          end
        end

        # Headers for API requests.
        #
        # @return [Hash] The request headers.
        def request_headers
          {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{token}"
          }
        end

        # Retrieve an authentication token for the Trelica API.
        #
        # @return [String] The authentication token.
        def token
          return @token if @token

          @token = conn.post(
            '/connect/token',
            'grant_type=client_credentials',
            token_headers
          ).body[:access_token]
        end

        # Headers for the token request.
        #
        # @return [Hash] The token request headers.
        def token_headers
          {
            'Content-Type' => 'application/x-www-form-urlencoded',
            'Authorization' => @config.trelica.basic_auth_header
          }
        end
      end
    end
  end
end
