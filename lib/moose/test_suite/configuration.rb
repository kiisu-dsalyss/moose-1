require 'ostruct'

module Moose
  module TestSuite
    class Configuration < Base
      class MissingEnvironment < Moose::Error; end

      include Hook::HookHelper
      attr_reader :runner

      def initialize(runner)
        @runner = runner
      end

      def register_environment(environment, environment_hash)
        environment_cache.merge!(environment.to_sym => OpenStruct.new(environment_hash))
      end

      def base_url
        environment_object.base_url
      end

      def load_file(file)
        Moose.load_suite_config_file(file: file, configuration: self)
      end

      def configure(&block)
        self.instance_eval(&block)
      end

      def suite_hook_collection
        @suite_hook_collection ||= Hook::Collection.new
      end

      def add_before_suite_hook(&block)
        create_before_hook_from(collection: suite_hook_collection, block: block)
      end

      def add_after_suite_hook(&block)
        create_after_hook_from(collection: suite_hook_collection, block: block)
      end

      def add_after_suite_teardown_hook(&block)
        create_after_teardown_hook_from(collection: suite_hook_collection, block: block)
      end

      def add_before_suite_teardown_hook(&block)
        create_before_teardown_hook_from(collection: suite_hook_collection, block: block)
      end

      def suite_teardown_hooks_with_entity(entity:, &block)
        suite_hook_collection.call_teardown_hooks_with_entity(entity: entity, raise_error: true, &block)
      end

      def run_test_case_with_hooks(test_case:, on_error: nil, &block)
        call_hooks_with_entity(entity: test_case, on_error: on_error, &block)
      end

      def run_teardown_with_hooks(test_case:, on_error: nil, &block)
        call_teardown_hooks_with_entity(entity: test_case, on_error: on_error, &block)
      end

      alias_method :before_each_test_case, :add_before_hook
      alias_method :after_each_test_case, :add_after_hook
      alias_method :around_each_test_case, :add_around_hook

      alias_method :before_each_test_case_teardown, :add_before_teardown_hook
      alias_method :after_each_test_case_teardown, :add_after_teardown_hook

      private

      def environment_object
        environment_cache.fetch(runner.environment) {
          raise MissingEnvironment.new("no environment setup for #{runner.environment}")
        }
      end

      def environment_cache
        @environment_cache ||= {}
      end
    end
  end
end
