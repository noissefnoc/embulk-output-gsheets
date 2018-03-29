require 'googleauth'
require 'google/apis/sheets_v4'

module Embulk
  module Output
    class Gsheets < OutputPlugin
      class Auth
        def initialize(task)
          @credentials_path = task['credentials_path']
          @client_secrets_path = task['client_secrets_path']
        end

        def authorize
          FileUtils.mkdir_p(File.dirname(@credentials_path))

          client_id = Google::Auth::ClientId.from_file(@client_secrets_path)
          token_store = Google::Auth::Stores::FileTokenStore.new(file: @credentials_path)
          authorizer = Google::Auth::UserAuthorizer.new(client_id, scope, token_store)
          user_id = 'default'

          # read credentials from local cached file
          credentials = authorizer.get_credentials(user_id)

          # get credentials from api request
          if credentials.nil?
            begin
              url = authorizer.get_authorization_url(base_url: oob_uri)
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
                  user_id: user_id, code: code, base_url: oob_uri)
            rescue => e
              # TODO: more appropriate error handling
              raise "Could not get auth URL from Google #{e.message}" +
                        "client_secrets = #{@client_secrets_path}"
            end
          end
          credentials
        end

        def self.default_credentials_path
          File.expand_path('~/.config/gcloud/embulk-output-gsheets.yml')
        end

        private

        def scope
          Google::Apis::SheetsV4::AUTH_SPREADSHEETS
        end

        def oob_uri
          'urn:ietf:wg:oauth:2.0:oob'
        end
      end
    end
  end
end
