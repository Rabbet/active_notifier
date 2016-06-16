class ActiveNotifier::MessageQueue
  cattr_accesor :client
  self.client = Redis

  def initialize
    @client = self.class.client.new
  end

  def push(message, status='awaiting_response')
    @client.lpush(to_key(message.to, status), serialize(message))
  end

  def pop(phone_number, status='awaiting_response')
    deserialize(@client.lpop(to_key(phone_number, status)))
  end

  def length(phone_number, status='awaiting_response')
    @client.llen(to_key(phone_number, status))
  end

  private
  def to_key(phone_number, status)
    "#{phone_number}:#{status}"
  end

  def serialize(message)
    "#{message.class}|#{message.event}|#{message.serialized_arguments}"
  end

  def deserialize(serialized_message)
    klass, event, *args = serialized_message.split('|')
    klass = klass.constantize
    event = event.to_sym

    klass.new(event, *klass.deserialize(args))
  end
end
