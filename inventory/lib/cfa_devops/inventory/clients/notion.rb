# frozen_string_literal: true

require_relative 'base'

module CfaDevops
  module Inventory
    module Clients
      # Client for interacting with the Notion API.
      class Notion < Base
        API_VERSION = '2025-09-03'
        DEFAULT_RESULTS_PER_PAGE = 100

        class UserNotFoundError < ArgumentError; end

        # Retrieve a database by its ID.
        #
        # @param id [String] The ID of the database.
        # @return [Hash] The database details.
        def database(id:)
          conn.get("databases/#{id}").body
        end

        # Retrieve a data source by its ID.
        #
        # @param id [String] The ID of the data source.
        # @return [Hash] The data source details.
        def data_source(id:)
          conn.get("data_sources/#{id}").body
        end

        # Retrieve a page from a data source its name.
        #
        # If more than one page matches, only the first is returned.
        #
        # @param id [String] The ID of the data source.
        # @param name [String] The name of the page.
        # @return [Hash, nil] The page details or nil if not found.
        def data_source_entry_by_name(id:, name:)
          conn.post("data_sources/#{id}/query", {
                      filter: {
                        property: 'Name',
                        title: {
                          equals: name
                        }
                      }
                    }).body[:results].first
        end

        # Create a new page within a data source.
        #
        # @param parent_id [String] The ID of the parent data source.
        # @param properties [Hash] The properties of the new page.
        # @param icon [Hash, nil] The icon for the new page.
        def create_page(parent_id:, properties:, icon: nil)
          conn.post('pages', {
                      parent: { data_source_id: parent_id },
                      properties:,
                      icon:
                    }).body
        end

        # Update an existing page.
        #
        # @param id [String] The ID of the page to update.
        # @param properties [Hash] The updated properties of the page.
        # @param icon [Hash, nil] The updated icon for the page.
        def update_page(id:, properties:, icon: nil)
          conn.patch("pages/#{id}", { icon:, properties: }).body
        end

        # Look up a user ID by their email address.
        #
        # @param email [String] The email address of the user.
        # @return [String] The user ID.
        #
        # @raise [UserNotFoundError] If no user is found with the given email.
        def user_id_by_email(email:)
          raise UserNotFoundError, 'Unable to find user by email.' unless user_emails[email]

          user_emails[email]
        end

        # List all users in the Notion workspace.
        #
        # @return [Array<Hash>] List of users.
        def users
          users = []
          params = { page_size: DEFAULT_RESULTS_PER_PAGE }

          loop do
            response = conn.get('users', params).body
            users.concat(response[:results])
            params[:start_cursor] = response[:next_cursor]

            break unless response[:has_more]
          end

          users
        end

        private

        def user_emails
          @user_emails ||= users.to_h do |user|
            next [nil, nil] unless user[:type] == 'person'

            [user[:person][:email], user[:id]]
          end.compact
        end

        # Establish a connection to the Notion API.
        #
        # @return [Faraday::Connection] The Faraday connection object.
        def conn
          @conn = Faraday.new 'https://api.notion.com/v1' do |conn|
            conn.request :json
            conn.response :json, parser_options: { symbolize_names: true }
            conn.response :raise_error
            conn.headers = {
              'Content-Type' => 'application/json',
              'Authorization' => "Bearer #{@config.notion.api_token}",
              'Notion-Version' => API_VERSION
            }
          end
        end
      end
    end
  end
end
