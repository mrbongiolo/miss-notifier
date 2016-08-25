require 'dry-container'

module Miss
  module Notifier
    module Messenger
      class Clients
        extend Dry::Container::Mixin
      end
    end
  end
end
