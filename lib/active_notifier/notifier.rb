class ActiveNotifier::Notifier
  class << self
    def notifies_on(event, via)
      events[event] = { methods: via }
    end

    def respond_to_missing?(method_name, include_private = false)
      events.has_key?(method_name) || super
    end

    def method_missing(event, *args)
      if respond_to?(event)
        ActiveNotifier::Notification.new(event, events[event], *args)
      else
        super
      end
    end

    private
    def events
      @events ||= {}
    end
  end
end
