require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

module Embulk
  module Output
    class Gsheets < OutputPlugin
      class Service
        OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
        SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS
        DEFAULT_START_RANGE = 'A1:A1'.freeze

        def initialize(task)
          @spreadsheet_id = task['spreadsheet_id']
          @sheet_name = task['sheet_name']
          @client_secrets_path = task['client_secrets_path']
          @credential_path = task['credential_path']
          @application_name = task['application_name']

          service = Google::Apis::SheetsV4::SheetsService.new
          service.client_options.application_name = @application_name
          service.authorization = authorize

          @service = service
        end

        def authorize
          FileUtils.mkdir_p(File.dirname(@credential_path))

          client_id = Google::Auth::ClientId.from_file(@client_secrets_path)
          token_store = Google::Auth::Stores::FileTokenStore.new(file: @credential_path)
          authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
          user_id = 'default'

          # read credentials from local cached file
          credentials = authorizer.get_credentials(user_id)

          # get credentials from api request
          if credentials.nil?
            begin
              url = authorizer.get_authorization_url(base_url: OOB_URI)
            rescue => e
              # TODO: more appropriate error handling
              raise "Could not get auth URL from Google #{e.message}" +
                        "client_secrets = #{@client_secrets_path}"
            end
            # diaplay authentication url
            puts 'Open the following URL in the browser and enter the ' +
                     'resulting code after authorization'
            puts url
            # wait for user input
            code = gets
            begin
              credentials = authorizer.get_and_store_credentials_from_code(
                  user_id: user_id, code: code, base_url: OOB_URI)
            rescue => e
              # TODO: more appropriate error handling
              raise "Could not get auth URL from Google #{e.message}" +
                        "client_secrets = #{@client_secrets_path}"
            end
          end
          credentials
        end

        def write(bulk_record)
          range = @sheet_name + '!' + DEFAULT_START_RANGE
          value_range_object = Google::Apis::SheetsV4::ValueRange.new(values: bulk_record)
          begin
            # TODO: check response if write values correctly
            response = @service.append_spreadsheet_value(
                @spreadsheet_id, range, value_range_object, value_input_option: 'RAW')
          rescue => e
            # TODO: more appropriate error handling
            raise "Could not write values to Google Sheets #{e.message}" +
                      "spreadsheet_id = #{@spreadsheet_id}, range = #{range}"
          end
        end

        def get_values(range)
          values = nil
          begin
            response = @service.get_spreadsheet_values(@spreadsheet_id, range)
            values = response.values
          rescue => e
            # TODO: more appropriate error handling
            raise "Could not get values from Google Sheets #{e.message}" +
                "spreadsheet_id = #{@spreadsheet_id}, range = #{range}"
          end
          values
        end

        def get_header
          range = @sheet_name + '!' + DEFAULT_START_RANGE
          header = get_values(range)
          header
        end
      end
    end
  end
end
