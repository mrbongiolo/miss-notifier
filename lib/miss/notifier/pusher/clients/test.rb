module Miss
  module Notifier
    module Pusher
      class Clients

        class Test

          def self.deliveries
            @deliveries ||= []
          end

          def deliveries
            self.class.deliveries
          end

          def call(to:, body:, extras: {}, opts: {})
            deliveries << {
              to: to,
              body: body,
              extras: extras,
              opts: opts
            }
          end
        end

        register :test, Test.new
      end
    end
  end
end
