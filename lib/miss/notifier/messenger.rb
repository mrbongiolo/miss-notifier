require "miss/notifier"
require "hanami/utils/string"

module Miss
  module Notifier
    module Messenger
      include Miss::Notifier::SharedMethods

      def self.included(base)
        base.class_eval do
          extend DSL
          extend Miss::Notifier::ClassMethods
        end
      end

      module DSL
        extend Miss::Notifier::DSLBuilder

        param :from, default: Miss::Notifier.config.messenger.sender_number
        param :to
        param :body
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
    end
  end
end
