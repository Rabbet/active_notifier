require 'active_job/arguments'

class ActiveNotifier::Messenger
  extend ::ActiveJob::Arguments

  cattr_accessor :client, :message_queue
  cattr_reader :default_options
  attr_reader :event, :to, :from, :body, :arguments, :client, :message_queue, :response_message

  self.client = ActiveNotifier::Clients::SMS
  self.message_queue = ActiveNotifier::MessageQueue

  class << self
    def method_missing(method, *args)
      if event_handlers.has_key?(method)
        self.new(method, *args)
      else
        super
      end
    end

    def default_options
      @default_options ||= {}
    end

    def event_handlers
      @event_handlers ||= {}
    end

    def response_handlers
      @response_handlers ||= HashWithIndifferentAccess.new
    end

    def default(options = {})
      @default_options = options
    end

    def event(event, &block)
      event_handlers[event] = block
    end

    def on_response_to(event, &block)
      response_handlers[event] = block
    end

    def process_response(phone_number, response)
      if message = message_queue.new.pop(phone_number, 'awaiting_response')
        message.process_response(response)
      end
    end

    def next_pending_message(phone_number)
      message_queue.new.pop(phone_number, 'not_sent')
    end
  end

  def initialize(event, *args)
    @event = event

    @to =   format_phone_number(self.class.default_options[:to])
    @from = format_phone_number(self.class.default_options[:from])
    @body = self.class.default_options[:body]

    @arguments = args

    @message_queue = self.class.message_queue.new
    @client = self.class.client.new
  end

  def deliver(options = {})
    self.class.event_handlers[@event].call(@arguments)

    if !self.class.response_handlers.has_key?(@event)
      send_sms(options)
    elsif @message_queue.length(@to, 'awaiting_response') == 0
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

  def sms(options = {})
    @to = options[:to] unless options[:to].nil?
    @from = options[:from] unless options[:from].nil?
    @body = options[:body] unless options[:body].nil?
  end

  private
  def body(message)
    @response_message = message
  end

  def process_response(response)
    self.class.response_handlers[@event].call(response, *@arguments)
    return @response_message
  end

  def send_sms(options)
    @client.send_message(from: @from, to: @to, body: @body)
  end

  def queue_message(status)
    @message_queue.push(self, status)
  end

  def format_phone_number(phone_number)
    phone_number ? phone_number.gsub(/\D/, '').gsub('+1', '') : ''
  end
end
