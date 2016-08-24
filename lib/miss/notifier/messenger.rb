require "hanami/utils/string"

module Miss
  module Notifier
    module Messenger

      module DSL

        def from(value = nil)
          if value.nil?
            @from ||= config.messenger.sender_number
          else
            @from = value
          end
        end

        def to(value = nil)
          value.nil? ? @to : @to = value
        end

        def body(value = nil)
          value.nil? ? @body : @body = value
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
        @delivery_method = self.class.config.messenger.delivery_method
        @delivery_client = delivery_client_class.new(
          from: __dsl(:from),
          to: __dsl(:to),
          body: __dsl(:body),
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
          "Miss::Notifier::Messenger::Clients::#{ Hanami::Utils::String.new(client_name).classify }"
        )
      end

      def extract_delivery_method_options(client_name, **opts)
        opts
      end
    end
  end
end
