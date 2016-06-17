require 'spec_helper'

describe ActiveNotifier::Messenger do
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

  describe '#deliver' do
    context 'event has no responder' do
      it 'sends the sms' do

      end
    end

    context 'event has a responder but not pending messages' do
      it 'sends the sms and adds the response to the queue with the status "awaiting_response"' do

      end
    end

    context 'event has a responder and a pending message' do
      it 'does not send the sms and adds the response to the queue with the status "not_sent"' do

      end
    end
  end

  describe '#deliver_later' do
    it 'enqueues a job to attempt delivery later' do

    end
  end

  describe '#serialized_arguments' do
    it 'serializes the arguments' do

    end
  end
end
