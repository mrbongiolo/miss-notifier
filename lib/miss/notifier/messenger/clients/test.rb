module Miss
  module Notifier
    module Messenger
      module Clients

        class Test

          def initialize(from:, to:, body:, opts: {})
            @from = from
            @to = to
            @body = body
            @opts = opts
          end

          def self.deliveries
            @deliveries ||= []
          end

          def deliver
            self.class.deliveries << { from: @from,
                                       to: @to,
                                       body: @body,
                                       opts: @opts }
          end
        end
      end
    end
  end
end
