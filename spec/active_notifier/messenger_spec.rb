require 'spec_helper'

describe ActiveNotifier::Messenger do
  ActiveNotifier::MessageQueue.client = FakeMessageQueue
  ActiveNotifier::Clients::SMS.client = FakeSMS

  let(:from) { '5125551234' }
  let(:to) { '5125554321' }
  let(:body) { 'hello!' }
  let(:message) { ActiveNotifier::Messenger.new(:foo).tap { |m| m.send(:sms, to: to, from: from, body: body) } }

  after :each do
    ActiveNotifier::Messenger.send(:instance_variable_set, :@event_handlers, nil)
    ActiveNotifier::Messenger.send(:instance_variable_set, :@default_options, nil)
    ActiveNotifier::Messenger.send(:instance_variable_set, :@response_handlers, nil)
    FakeMessageQueue.queue = Hash.new([])
  end

  describe '.default' do
    it 'sets the default options' do
      options = { to: '5125551234', from: '5125551234', body: 'foo' }
      ActiveNotifier::Messenger.default(options)
      expect(ActiveNotifier::Messenger.default_options).to eq(options)
    end
  end

  describe '.event' do
    it 'stores the block passed for the event' do
      block = -> { 'foo' }
      ActiveNotifier::Messenger.event :foo, &block
      expect(ActiveNotifier::Messenger.event_handlers[:foo]).to eq(block)
    end
  end

  describe '.on_response_to' do
    it 'stores the responder block for an event' do
      block = -> { 'foo' }
      ActiveNotifier::Messenger.on_response_to :foo, &block
      expect(ActiveNotifier::Messenger.response_handlers[:foo]).to eq(block)
    end
  end

  describe '.method_missing' do
    it "raises an error if the event doesn't exist" do
      expect { ActiveNotifier::Messenger.does_not_exist }.to raise_error(NoMethodError)
    end

    it 'calls new with the method name if the event exists' do
      ActiveNotifier::Messenger.event(:foo) { 'foo' }
      expect(ActiveNotifier::Messenger).to receive(:new).with(:foo)
      ActiveNotifier::Messenger.foo
    end
  end

  describe '#deliver' do
    before(:each) { ActiveNotifier::Messenger.event(:foo) { 'foo' } }

    context 'event has no responder' do
      it 'sends the sms' do
        expect(message.client).to receive(:send_message).with(from: from, to: to, body: body)
        expect(message.message_queue).not_to receive(:push)
        message.deliver
      end
    end

    context 'event has a responder but not pending messages' do
      it 'sends the sms and adds the response to the queue with the status "awaiting_response"' do
        ActiveNotifier::Messenger.on_response_to(:foo) { 'foo' }
        expect(message.client).to receive(:send_message).with(from: from, to: to, body: body)
        expect(message.message_queue).to receive(:push).with(message, 'awaiting_response')
        message.deliver
      end
    end

    context 'event has a responder and a pending message' do
      it 'does not send the sms and adds the response to the queue with the status "not_sent"' do
        ActiveNotifier::Messenger.on_response_to(:foo) { 'foo' }
        message.deliver

        expect(message.client).not_to receive(:send_message)
        expect(message.message_queue).to receive(:push).with(message, 'not_sent')
        message.deliver
      end
    end
  end

  describe '#deliver_later' do
    it 'enqueues a job to attempt delivery later' do

    end
  end

  describe '#serialized_arguments' do
    it 'serializes the arguments' do
      message = ActiveNotifier::Messenger.new(:foo, { foo: 'bar' })
      expect(message.serialized_arguments).to eq([{"foo"=>"bar", "_aj_symbol_keys"=>["foo"]}])
    end
  end
end
