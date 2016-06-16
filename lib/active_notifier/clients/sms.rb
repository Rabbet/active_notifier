class ActiveNotifier::Clients::SMS
  cattr_accessor :client
  self.client = Twilio::REST::Client

  def initialize
    @client = self.class.client.new
  end

  def send_message(from:, to:, body:)
    @client.messages.create(from: from, to: to, body: body)
  end
end
