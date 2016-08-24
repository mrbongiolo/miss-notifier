require 'spec_helper'

RSpec.describe Miss::Notifier::Pusher do

  require "miss/notifier/pusher/clients/test"

  class FakePusherUser < Struct.new(:name, :device_id); end

  class FakePusher
    include Miss::Notifier::Pusher

    to      :user_device_id
    body    :message
    extras  :android_params

    private

      def user_device_id
        user.device_id
      end

      def message
        "This is a message for #{ user.name }."
      end

      def android_params
        { android_sound: 'belldesk.wav' }
      end
  end

  class FakePusherWithLocals
    include Miss::Notifier::Pusher

    required_locals :user, :something

    to      'to'
    body    'body'
    extras  {}
  end


  describe "DSL" do

    describe ":required_locals" do

      context "when it's defined" do

        context "when using .deliver" do

          it "raise an ArgummentError if the local is not used" do
            expect do
              FakePusherWithLocals.deliver(user: 'user')
            end.to raise_error(ArgumentError, "missing locals: something")
          end

          it "raise an ArgummentError when there are unknown locals" do
            expect do
              FakePusherWithLocals
                .deliver(something: 's', oi: 'oi', user: 'user')
            end.to raise_error(ArgumentError, "unknown locals: oi")
          end
        end
      end

      context "when it's not defined" do

        context "when using .deliver" do

          it "accept any locals" do
            expect do
              FakePusher.deliver(
                user: FakePusherUser.new('Paul', 'fdi'),
                foo: 'foo'
              )
            end.to_not raise_error
          end
        end
      end
    end
  end


  describe '.deliver' do
    let(:message) { Miss::Notifier::Pusher.deliveries.last }
    let(:user) { FakePusherUser.new('John', 'fake_device_id_1234') }

    before(:each) do
      Miss::Notifier::Pusher.deliveries.clear
      FakePusher.deliver(user: user)
    end

    it 'delivers the message correctly' do
      expect(Miss::Notifier::Pusher.deliveries.size).to eql 1
    end

    it 'sends the correct information' do
      expect(message[:to]).to eql user.device_id
      expect(message[:body]).to eql "This is a message for #{ user.name }."
      expect(message[:extras]).to eql({ android_sound: 'belldesk.wav' })
      expect(message[:opts]).to be_empty
    end
  end
end