class ActiveNotifier::Notifier
  class << self
    def default(options={})
      @default_options = options
    end

    def notifies_on(event, via)
      events[event] = { methods: (default_options[:methods] || {}).merge(via) }
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

    def default_options
      @default_options ||= {}
    end
  end
end
