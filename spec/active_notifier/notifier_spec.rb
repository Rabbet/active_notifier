require 'spec_helper'

describe ActiveNotifier::Notifier do
  subject { SampleNotifier }
  describe '.method_missing' do
    context 'has matching event' do
      it 'creates a Notification object' do
        expect(subject.foo).to be_a(ActiveNotifier::Notification)
      end
    end

    context 'has no matching event' do
      it 'raises an error' do
        expect { subject.does_not_exist }.to raise_error
      end
    end
  end
end
