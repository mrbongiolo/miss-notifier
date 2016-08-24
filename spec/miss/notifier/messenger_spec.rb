require 'spec_helper'

RSpec.describe Miss::Notifier::Messenger do

  require "miss/notifier/messenger/clients/test"

  class FakeMessengerUser < Struct.new(:name, :cellphone); end

  class FakeMessenger
    include Miss::Notifier::Messenger

    from  '+551122223333'
    to    :user_number
    body  :message

    private

      def user_number
        user.cellphone
      end

      def message
        "This is a message for #{ user.name }."
      end
  end

  class FakeMessengerWithLocals
    include Miss::Notifier::Messenger

    required_locals :user, :something

    from  '+551122223333'
    to    'to'
    body  'body'
  end


  describe "DSL" do

    describe ":required_locals" do

      context "when it's defined" do

        context "when using .deliver" do

          it "raise an ArgummentError if the local is not used" do
            expect do
              FakeMessengerWithLocals.deliver(user: 'user')
            end.to raise_error(ArgumentError, "missing locals: something")
          end

          it "raise an ArgummentError when there are unknown locals" do
            expect do
              FakeMessengerWithLocals
                .deliver(something: 's', oi: 'oi', user: 'user')
            end.to raise_error(ArgumentError, "unknown locals: oi")
          end
        end

        # context "when using .deliver_later" do

        #   it "raise an ArgummentError if the local is not used" do
        #     expect do
        #       FakeMessengerWithLocals
        #         .deliver_later(job_options: { foo: 'foo' })
        #     end.to raise_error(ArgumentError, "missing locals: user, something")
        #   end

        #   it "raise an ArgummentError when there are unknown locals" do
        #     expect do
        #       FakeMessengerWithLocals
        #         .deliver_later(something: 's', oi: 'oi', user: 'user')
        #     end.to raise_error(ArgumentError, "unknown locals: oi")
        #   end
        # end
      end

      context "when it's not defined" do

        context "when using .deliver" do

          it "accept any locals" do
            expect do
              FakeMessenger.deliver(
                user: FakeMessengerUser.new('Paul', 'fdi'),
                foo: 'foo'
              )
            end.to_not raise_error
          end
        end

        # context "when using .deliver_later" do

        #   it "accept any locals" do
        #     expect do
        #       FakeMessenger.deliver_later(
        #         user: 'user',
        #         foo: 'foo'
        #       )
        #     end.to_not raise_error
        #   end
        # end
      end
    end
  end


  describe '.deliver' do
    let(:message) { Miss::Notifier::Messenger.deliveries.last }
    let(:user) { FakeMessengerUser.new('John', '+55 11 1234 1234') }

    before(:each) do
      Miss::Notifier::Messenger.deliveries.clear
      FakeMessenger.deliver(user: user)
    end

    it 'delivers the message correctly' do
      expect(Miss::Notifier::Messenger.deliveries.size).to eql 1
    end

    it 'sends the correct information' do
      expect(message[:from]).to eql '+551122223333'
      expect(message[:to]).to eql user.cellphone
      expect(message[:body]).to eql "This is a message for #{ user.name }."
      expect(message[:opts]).to be_empty
    end
  end


  # describe '.deliver_later' do
  #   let(:message) { Miss::Messenger.deliveries.last }
  #   let(:user) { create(:customer, name: 'Paul', cellphone: '+55 11 1234 4321') }

  #   context "with :job_options" do
  #     before(:each) do
  #       Miss::Messenger.deliveries.clear
  #       perform_enqueued_jobs do
  #         FakeMessenger.deliver_later(user: user,
  #                                     job_options: { wait: 600.seconds,
  #                                                    queue: :another_queue })
  #       end
  #     end

  #     it 'enqueues and delivers the message correctly' do
  #       expect(Miss::Messenger.deliveries.size).to eql 1
  #     end

  #     it 'enqueues the message with the right arguments' do
  #       later_time = Time.now.to_f + 3600
  #       assert_performed_with(job: Miss::Messenger::DeliveryJob,
  #                             at: later_time,
  #                             queue: 'another_queue',
  #                             args: [ 'FakeMessenger',
  #                                     { user: user } ]) do

  #         FakeMessenger.deliver_later(user: user,
  #                                     job_options: { wait_until: later_time,
  #                                                    queue: :another_queue })
  #       end
  #     end

  #     it 'sends the correct information' do
  #       expect(message[:from]).to eql '+551122223333'
  #       expect(message[:to]).to eql user.cellphone
  #       expect(message[:body]).to eql "This is a message for #{ user.name }."
  #       expect(message[:opts]).to be_empty
  #     end
  #   end

  #   context "without :job_options" do
  #     before(:each) do
  #       Miss::Messenger.deliveries.clear
  #       perform_enqueued_jobs do
  #         FakeMessenger.deliver_later(user: user)
  #       end
  #     end

  #     it 'enqueues and delivers the message correctly' do
  #       expect(Miss::Messenger.deliveries.size).to eql 1
  #     end

  #     it 'enqueues the message with the right arguments' do
  #       assert_performed_with(job: Miss::Messenger::DeliveryJob,
  #                             args: [ 'FakeMessenger',
  #                                     { user: user } ]) do
  #         FakeMessenger.deliver_later(user: user)
  #       end
  #     end

  #     it 'sends the correct information' do
  #       expect(message[:from]).to eql '+551122223333'
  #       expect(message[:to]).to eql user.cellphone
  #       expect(message[:body]).to eql "This is a message for #{ user.name }."
  #       expect(message[:opts]).to be_empty
  #     end
  #   end
  # end
end
