require 'spec_helper'

describe ActiveNotifier::Notification do
  class Notifier < ActiveNotifier::Notifier
    notifies_on :foo, { sms: ActiveNotifier::Messenger, messages: ActiveNotifier::Messenger }
  end

  let(:user) { Struct.new(:preferred_contact_methods).new([:sms]) }
  let(:message) { ActiveNotifier::Messenger.new(:foo) }

  before :each do
    allow(ActiveNotifier::Messenger).to receive(:foo).and_return(message)
  end

  describe '#deliver_later' do
    context 'user set' do
      it 'calls deliver_later on each of the set notification classes' do
        expect(message).to receive(:deliver_later).once
        Notifier.foo.for(user).deliver_later
      end
    end

    context 'no user set' do
      it 'calls deliver_later on each of the set notification classes' do
        expect(message).to receive(:deliver_later).twice
        Notifier.foo.deliver_later
      end
    end
  end

  describe '#deliver' do
    context 'user set' do
      it 'calls deliver on each of the set notification classes' do
        expect(message).to receive(:deliver_later).once
        Notifier.foo.for(user).deliver_later
      end
    end

    context 'no user set' do
      it 'calls deliver on each of the set notification classes' do
        expect(message).to receive(:deliver_later).twice
        Notifier.foo.deliver_later
      end
    end
  end
end
