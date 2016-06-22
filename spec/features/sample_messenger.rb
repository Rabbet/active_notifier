class SampleMessenger < ActiveNotifier::Messenger
  event :event_with_response do |string|
    sms(to: '5125551234', from: '5125554321', body: string)
  end

  on_response_to :event_with_response do |string|
    string
  end 

  event :event_without_response do |string|
    sms(to: '5125551234', from: '5125554321', body: string)
  end
end
