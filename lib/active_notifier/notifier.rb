class ActiveNotifier::Notifier
  class << self
    def notifies_on(event, via)
      events[event] = { methods: via }
    end

    def method_missing(event, *args)
      if events.has_key?(event)
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
