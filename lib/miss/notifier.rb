require "miss/notifier/version"
require "dry-configurable"

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

      def config
        Miss::Notifier.config
      end

      def deliver(locals={})
        new( check_locals!(locals) ).deliver
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


    module SharedMethods

      attr_reader :delivery_method_name,
        :delivery_method_options,
        :delivery_client

      def initialize(locals = {})
        @locals = locals
        @delivery_method_name, @delivery_method_options = \
          parse_delivery_method(*self.class.config.pusher.delivery_method)
        @delivery_client = clients_container[delivery_method_name]
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

      def parse_delivery_method(name, **options)
        [name, options]
      end

      def clients_container
        raise :not_declared, "This need to be declared."
      end
    end


    module DSLBuilder

      def param(name, default: nil)
        define_method(name, ->(value = nil) {
          if value.nil?
            instance_variable_get(:"@#{name}") ||
            instance_variable_set(:"@#{name}", default)
          else
            instance_variable_set(:"@#{name}", value)
          end
        })
      end
    end
  end
end
