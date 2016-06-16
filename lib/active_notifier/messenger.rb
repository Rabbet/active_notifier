class ActiveNotifier::Messenger
  extend Serialization

  cattr_accessor :client, :message_queue
  cattr_reader :default_options, :event_handlers
  attr_reader :to, :from, :body, :arguments

  self.client = ActiveNotifier::Clients::SMS
  self.message_queue = ActiveNotifier::MessageQueue.new

  class << self
    def method_missing(method, *args)
      if @events.has_key?(method)
        self.new(method, *args)
      else
        super
      end
    end

    def default(options = {})
      @default_options = options
    end

    def event(event, &block)
      @event_handlers ||= {}
      @event_handlers[event] = block
    end

    def on_response_to(event, &block)
      @response_handlers ||= HashWithIndifferentAccess.new
      @response_handlers[event] = block
    end
  end

  def initialize(event, *args)
    @event = event

    @to =   format_phone_number(self.class.default_options[:to])
    @from = format_phone_number(self.class.default_options[:from])
    @body = self.class.default_options[:body]

    @arguments = args
  end

  def deliver(options = {})
    self.class.event_handlers[@event].call(@arguments)

    if !self.class.responses.has_key?(@event)
      send_sms(options)
    elsif self.class.message_queue.length(@options[:to], 'awaiting_response') == 0
      send_sms(options)
      queue_message('awaiting_response')
    else
      queue_message('not_sent')
    end
  end

  def deliver_later(options = {})
    ActiveNotifier::NotificationJob.set(options).perform_later(self.class.to_s, @event, @arguments)
  end

  def serialized_arguments
    self.class.serialize(@arguments)
  end

  private
  def send_sms(options)
    self.class.client.send_message(from: @from, to: @to, body: @body)
  end

  def sms(options = {})
    @to = options[:to] unless options[:to].nil?
    @from = options[:from] unless options[:from].nil?
    @body = options[:body] unless options[:body].nil?
  end

  def queue_message(status)
    self.class.message_queue.push(self, status)
  end

  def format_phone_number(phone_number)
    phone_number.gsub(/\D/, '').gsub('+1', '')
  end
end
