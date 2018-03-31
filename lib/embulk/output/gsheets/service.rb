require_relative 'auth'

require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

module Embulk
  module Output
    class Gsheets < OutputPlugin
      class Service
        def initialize(task)
          @spreadsheet_id = task['spreadsheet_id']
          @sheet_name = task['sheet_name']
          @application_name = task['application_name']

          service = Google::Apis::SheetsV4::SheetsService.new
          service.client_options.application_name = @application_name
          service.authorization = Auth.new(task).authorize

          @service = service
        end

        def write(bulk_record)
          range = @sheet_name + '!' + default_start_range
          value_range_object =
            Google::Apis::SheetsV4::ValueRange.new(values: bulk_record)
          begin
            # TODO: check response if write values correctly
            @service.append_spreadsheet_value(
              @spreadsheet_id,
              range,
              value_range_object,
              value_input_option: 'RAW')
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
          range = @sheet_name + '!' + default_start_range
          get_values(range)
        end

        private

        def default_start_range
          'A1:A1'
        end
      end
    end
  end
end
