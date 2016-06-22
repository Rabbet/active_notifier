require 'spec_helper'

describe ActiveNotifier::MessageQueue do
  ActiveNotifier::MessageQueue.client = FakeMessageQueue

  subject { ActiveNotifier::MessageQueue.new }
  let(:message) { ActiveNotifier::Messenger.new(:foo, 'a string') }

  describe '#push' do
    it 'serializes and pushes the message to the queue' do
      message.send(:sms, to: '5125551234')

      subject.push(message, 'awaiting_response')

      serialized_message = subject.client.queue['5125551234:awaiting_response'].first
      expect(Marshal.load(serialized_message)).to eq(['ActiveNotifier::Messenger', :foo, message.to, message.from, message.body, ['a string']])
    end
  end

  describe '#pop' do
    it 'pops and deserializes the message' do
      subject.client.queue['5125551234:awaiting_response'] = ['ActiveNotifier::Messenger|foo|["a string"]']
      message = subject.pop('5125551234:awaiting_response')
      expect(message.arguments).to eq(['a string'])
      expect(message.event).to eq(:foo)
    end
  end

  describe '#length' do
    it 'returns the length of the queue for a given phone number and status' do
      message.send(:sms, to: '5125551234')
      5.times { subject.push(message, 'not_sent') }
      expect(subject.length(message.to, 'not_sent')).to eq(5)
    end
  end
end
