require_relative 'gsheets/service'
require_relative 'gsheets/auth'

require 'fileutils'

module Embulk
  module Output

    class Gsheets < OutputPlugin
      Plugin.register_output("gsheets", self)

      def self.transaction(config, schema, count, &control)
        task = {
          'spreadsheet_id' => config.param('spreadsheet_id', :string),
          'sheet_name' => config.param('sheet_name', :string),
          'client_secrets_path' => config.param('client_secrets_path', :string),
          'credential_path' => config.param('credential_path', :string, default: Auth::default_credentials_path),
          'application_name' => config.param('application_name', :string, default: 'embulk-output-gsheets'),
          'bulk_num' => config.param('bulk_num', :integer, default: 200),
          'with_header' => config.param('with_header', :bool, default: true),
        }

        Embulk.logger.info "Writing google sheets: " +
                               "spreadsheet id = [#{task['spreadsheet_id']}], sheet name = [#{task['sheet_name']}]"

        service = Service.new(task)
        header = service.get_header

        if task['with_header'] && header.nil?
          header_record = schema.map { |s| s['name'] }
          service.write([header_record])
        end

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
        # nothing to do
      end

      def add(page)
        page.each do |record|
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
        # nothing to do
      end

      def commit
        task_report = {}
        return task_report
      end
    end
  end
end
