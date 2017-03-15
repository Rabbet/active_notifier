require 'spec_helper'

describe ActiveNotifier::Notification do
  class Notifier < ActiveNotifier::Notifier
    notifies_on :foo, { sms: ActiveNotifier::Messenger, messages: ActiveNotifier::Messenger }
  end

  let(:user) { Struct.new(:preferred_contact_methods).new([:sms]) }
  let(:message) { ActiveNotifier::Messenger.new(:foo, 'fizz', 'buzz') }

  before :each do
    expect(ActiveNotifier::Messenger).to receive(:foo).with('fizz', 'buzz').at_least(:once).and_return(message)
  end

  describe '#deliver_later' do
    context 'methods defined' do
      it 'calls deliver_later on each of the set notification classes' do
        expect(message).to receive(:deliver_later).once
        Notifier.foo('fizz', 'buzz').using(:sms).deliver_later
      end
    end

    context 'no methods defined' do
      it 'calls deliver_later on each of the set notification classes' do
        expect(message).to receive(:deliver_later).twice
        Notifier.foo('fizz', 'buzz').deliver_later
      end
    end
  end

  describe '#deliver' do
    context 'methods defined' do
      it 'calls deliver on each of the set notification classes' do
        expect(message).to receive(:deliver).once
        Notifier.foo('fizz', 'buzz').using(:sms).deliver
      end
    end

    context 'no methods defined' do
      it 'calls deliver on each of the set notification classes' do
        expect(message).to receive(:deliver).twice
        Notifier.foo('fizz', 'buzz').deliver
      end
    end
  end
end
