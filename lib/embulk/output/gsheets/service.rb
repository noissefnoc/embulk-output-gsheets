require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

module Embulk
  module Output
    class Gsheets < OutputPlugin
      class Service
        OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
        SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

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
            url = authorizer.get_authorization_url(
                base_url: OOB_URI)
            puts 'Open the following URL in the browser and enter the ' +
                     'resulting code after authorization'
            puts url
            code = gets
            credentials = authorizer.get_and_store_credentials_from_code(
                user_id: user_id, code: code, base_url: OOB_URI)
          end
          credentials
        end

        def write(bulk_record)
          range = @sheet_name + '!A2:B2'
          value_range_object = Google::Apis::SheetsV4::ValueRange.new(values: bulk_record)
          response = @service.append_spreadsheet_value(
              @spreadsheet_id, range, value_range_object, value_input_option: 'RAW')
        end
      end
    end
  end
end