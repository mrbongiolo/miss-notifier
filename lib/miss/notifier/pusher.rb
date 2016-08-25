require "miss/notifier"
require "miss/notifier/pusher/clients"

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
        Clients[:test].deliveries
      end

      def deliver
        delivery_client.call(
          to: __dsl(:to),
          body: __dsl(:body),
          extras: __dsl(:extras),
          opts: delivery_method_options
        )
      end

      private

      def clients_container
        Miss::Notifier::Pusher::Clients
      end
    end
  end
end
