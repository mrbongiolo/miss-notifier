require "miss/notifier"
require "miss/notifier/messenger/clients"

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
        Clients[:test].deliveries
      end

      def deliver
        delivery_client.call(
          from: __dsl(:from),
          to: __dsl(:to),
          body: __dsl(:body),
          opts: delivery_method_options
        )
      end

      private

      def clients_container
        Miss::Notifier::Messenger::Clients
      end
    end
  end
end
