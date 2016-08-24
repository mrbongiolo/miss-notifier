require "miss/notifier"
require "hanami/utils/string"

module Miss
  module Notifier
    module Pusher
      include SharedMethods

      def self.included(base)
        base.class_eval do
          extend DSL
          extend Miss::Notifier::ClassMethods
        end
      end

      module DSL
        extend Miss::Notifier::DSLBuilder

        param :to
        param :body
        param :extras, default: {}
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
    end
  end
end
