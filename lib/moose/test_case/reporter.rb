module Meese
  class TestCase
    class Reporter
      attr_reader :test_case

      def initialize(test_case)
        @test_case = test_case
      end

      def final_report!
        return if test_case.passed?
        with_details do
          if test_case.failed?
            failure_script
            rerun_script
          end
        end
      end

      def report!
        with_details do
          if test_case.failed?
            failure_script
          elsif test_case.passed?
            passed_script
          end
        end
      end

      def rerun_script
        newline
        message_with(:info, "To Rerun")
        message_with(:info, "bundle exec moose #{test_case.trimmed_filepath}")
      end

      private

      def err
        test_case.exception
      end

      def trimmed_backtrace
        paths = err.backtrace.take_while { |backtrace_path|
          !(backtrace_path =~ /^#{gem_spec.gem_dir}\//)
        }
        paths.map { |path|
          "\t#{Utilities::FileUtils.trim_filename(path)}"
        }
      end

      def with_details(&block)
        newline
        message_with(:name, test_case.trimmed_filepath)
        message_with(:info, "time: #{test_case.time_elapsed}")
        newline

        block.call

        newline
      end

      def failure_script
        message_with(:failure, "TEST failed")
        if err
          message_with(:error, err.class)
          message_with(:error, err.message)
          Meese.msg.report_array(:error, trimmed_backtrace)
        end
      end

      def passed_script
        message_with(:pass, "TEST Passed!")
      end

      def newline
        Meese.msg.newline
      end

      def message_with(type, message)
        Meese.msg.send(type, "\t#{message}")
      end

      def gem_spec
        Gem::Specification.find_by_name("moose")
      end
    end
  end
end
