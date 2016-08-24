module Miss
  module Notifier
    module Pusher
      module Clients

        class Test

          def initialize(to:, body:, extras: {}, opts: {})
            @to = to
            @body = body
            @extras = extras
            @opts = opts
          end

          def self.deliveries
            @deliveries ||= []
          end

          def deliver
            self.class.deliveries << { to: @to,
                                       body: @body,
                                       extras: @extras,
                                       opts: @opts }
          end
        end
      end
    end
  end
end
