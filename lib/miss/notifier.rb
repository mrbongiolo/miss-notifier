require "miss/notifier/version"
require "miss/notifier/messenger"
require "miss/notifier/pusher"

require "dry/configurable"

module Miss
  module Notifier
    extend Dry::Configurable

    setting :messenger do
      setting :delivery_method, :test
      setting :sender_number
    end

    setting :pusher do
      setting :delivery_method, :test
    end

    module ClassMethods

      def deliver(locals={})
        new( check_locals!(locals) ).deliver
      end

      def config
        Miss::Notifier.config
      end

      def required_locals(*value)
        if value.empty?
          @required_locals ||= nil
        else
          @required_locals = value
        end
      end

      def check_locals!(locals)
        return locals unless required_locals
        unless (missing_locals = required_locals - locals.keys).empty?
          raise ArgumentError, "missing locals: #{missing_locals.join(', ')}"
        end
        unless (unknown_locals = locals.keys - required_locals).empty?
          raise ArgumentError, "unknown locals: #{unknown_locals.join(', ')}"
        end
        locals
      end
    end
  end
end
