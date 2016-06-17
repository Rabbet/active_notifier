class SampleNotifier < ActiveNotifier::Notifier
  notifies_on :foo, via: { sms: SampleMessenger }
end
