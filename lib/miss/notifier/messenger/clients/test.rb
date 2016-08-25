module Miss
  module Notifier
    module Messenger
      class Clients

        class Test

          def self.deliveries
            @deliveries ||= []
          end

          def deliveries
            self.class.deliveries
          end

          def call(from:, to:, body:, opts: {})
            deliveries << {
              from: from,
              to: to,
              body: body,
              opts: opts
            }
          end
        end

        register :test, Test.new
      end
    end
  end
end
