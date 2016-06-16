class ActiveNotifier::Clients::Phone
  cattr_accessor :client
  self.client = Twilio::REST::Client

  def initialize
    @client = self.class.client.new
  end

  def connect_call(from:, to:, on_connect_url:)
    raise 'not implemented'
  end
end
