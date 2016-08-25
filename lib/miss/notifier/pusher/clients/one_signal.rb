require 'one_signal'

module Miss
  module Notifier
    module Pusher
      class Clients

        class OneSignal

          def call(to:, body:, extras: {}, opts: {})
            @to = to
            @body = body
            @extras = extras
            @opts = opts
            @api_key = opts[:api_key]

            deliver
          end

          private

          def deliver
            ::OneSignal::Notification
              .create(params: build_params, opts: { api_key: @api_key })
          end

          def build_params
            {
              headings: { en: "Title" },
              contents: { en: @body },
              include_player_ids: @to
            }.reverse_merge(@extras)
          end
        end

        register :one_signal, OneSignal.new
      end
    end
  end
end
