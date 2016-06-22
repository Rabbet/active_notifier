require 'redis'

class ActiveNotifier::MessageQueue
  cattr_accessor :client
  self.client = ::Redis

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

  def clear
    @client.flushall
  end

  private
  def to_key(phone_number, status)
    "#{phone_number}:#{status}"
  end

  def serialize(message)
    Marshal.dump([message.class.to_s, message.event, message.to, message.from, message.body, message.serialized_arguments])
  end

  def deserialize(serialized_message)
    return if serialized_message.nil?

    klass, event, to, from, body, args = Marshal.load(serialized_message)
    klass = klass.constantize
    event = event.to_sym

    klass.new(event, *klass.deserialize(args)).tap { |message| message.sms(to: to, from: from, body: body) }
  end
end
