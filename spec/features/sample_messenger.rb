class SampleMessenger < ActiveNotifier::Messenger
  event :foo do |string|
    sms(to: '5125551234', from: '5125554321', body: string)
  end

  on_response_to :foo do |string|
    string
  end 
end
