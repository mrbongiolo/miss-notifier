require 'hanami/utils/string'

module Miss
  module Notifier
    module Pusher

      module DSL

        def to(value = nil)
          value.nil? ? @to : @to = value
        end

        def body(value = nil)
          value.nil? ? @body : @body = value
        end

        def extras(value = nil)
          value.nil? ? @extras : @extras = value
        end
      end

      def self.included(base)
        base.class_eval do
          extend DSL
          extend Miss::Notifier::ClassMethods
        end
      end

      def self.deliveries
        Clients::Test.deliveries
      end

      def initialize(locals = {})
        @locals = locals
        @delivery_method = self.class.config.pusher.delivery_method
        @delivery_client = delivery_client_class.new(
          to: __dsl(:to),
          body: __dsl(:body),
          extras: __dsl(:extras),
          opts: extract_delivery_method_options(*@delivery_method))
      end

      def deliver
        @delivery_client.deliver
      end

      protected

      def method_missing(m)
        @locals.fetch(m) { super }
      end

      private

      def __dsl(method_name)
        case result = self.class.__send__(method_name)
        when Symbol
          __send__(result)
        else
          result
        end
      end

      def delivery_client_class
        @delivery_client_class ||= get_delivery_client_class(*@delivery_method)
      end

      def get_delivery_client_class(client_name, *)
        Kernel.const_get(
          "Miss::Notifier::Pusher::Clients::#{ Hanami::Utils::String.new(client_name).classify }"
        )
      end

      def extract_delivery_method_options(client_name, **opts)
        opts
      end
    end
  end
end
