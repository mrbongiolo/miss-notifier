require "miss/notifier/version"
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


    module SharedMethods

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

      def get_delivery_client_class(client_name, **_)
        Kernel.const_get(
          "#{self.class.ancestors[1]}::Clients::#{ Hanami::Utils::String.new(client_name).classify }"
        )
      end

      def extract_delivery_method_options(client_name, **opts)
        opts
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
