require 'plivo'

module Miss
  module Notifier
    module Messenger
      class Clients

        class Plivo

          def call(from:, to:, body:, opts: {})
            @from = from
            @to = to
            @body = body
            @auth_id = opts[:auth_id]
            @auth_token = opts[:auth_token]

            deliver
          end

          private

          def deliver
            plivo_rest_api.send_message(src: @from,
                                        dst: @to,
                                        text: @body,
                                        type: 'sms')
          end

          def plivo_rest_api
            @plivo_rest_api ||= ::Plivo::RestAPI.new(@auth_id, @auth_token)
          end
        end

        register :plivo, Plivo.new
      end
    end
  end
end
