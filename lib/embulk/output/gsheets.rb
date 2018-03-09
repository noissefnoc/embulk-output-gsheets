require_relative 'gsheets/service'

require 'fileutils'

module Embulk
  module Output

    class Gsheets < OutputPlugin
      Plugin.register_output("gsheets", self)

      def self.transaction(config, schema, count, &control)
        credential_default_path = File.join(
            Dir.home,
            '.credentials',
            'embulk-output-gsheets.yml')

        task = {
          'spreadsheet_id' => config.param('spreadsheet_id', :string),
          'sheet_name' => config.param('sheet_name', :string),
          'client_secrets_path' => config.param('client_secrets_path', :string),
          'credential_path' => config.param('credential_path', :string, default: credential_default_path),
          'application_name' => config.param('application_name', :string, default: 'embulk-output-gsheets'),
          'bulk_num' => config.param('bulk_num', :integer, default: 200),
        }

        task_reports = yield(task)
        next_config_diff = {}
        return next_config_diff
      end

      # def self.resume(task, schema, count, &control)
      #   task_reports = yield(task)
      #
      #   next_config_diff = {}
      #   return next_config_diff
      # end

      def init
        @service = Service.new(task)
        @bulk_num = task['bulk_num']
        @bulk_record = []
      end

      def close
      end

      def add(page)
        page.each do |record|
          #hash = Hash[schema.names.zip(record)]
          @bulk_record << record
          if @bulk_num <= @bulk_record.size
            @service.write(@bulk_record)
            @bulk_record.clear
          end
        end
      end

      def finish
        if @bulk_record.size > 0
          @service.write(@bulk_record)
        end
      end

      def abort
      end

      def commit
        task_report = {}
        return task_report
      end
    end
  end
end
