require 'spec_helper'

describe ActiveNotifier::NotificationJob do
  subject { ActiveNotifier::NotificationJob.new }
  describe '#perform' do
    let(:method) { :foo }
    let(:klass) { ActiveNotifier::Messenger }
    let(:arguments) { ['bar'] }
    let(:notifier_double) { instance_double('notifier', deliver: true) }

    it 'delivers the notification' do
      klass.event(:foo) { |bar| bar }
      expect(klass).to receive(method).with(*arguments).and_return(notifier_double)
      subject.perform(klass.to_s, method, *arguments)
    end
  end
end
