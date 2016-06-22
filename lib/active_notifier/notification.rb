class ActiveNotifier::Notification
  def initialize(event, event_options, *args)
    @event = event
    @event_options = event_options
    @args = args
    @for = nil
  end

  def for(user)
    self.tap do
      @for = user
    end
  end

  def deliver_later(options = {})
    methods_used.each do |notification_class|
      notification_class.send(@event, @args).deliver_later(options)
    end
  end

  def deliver(options = {})
    methods_used.each do |notification_class|
      notification_class.send(@event, @args).deliver(options)
    end
  end

  private
  def methods_used
    if @for.nil?
      @event_options[:methods].values
    else
      @event_options[:methods].select { |method, _| @for.preferred_contact_methods.include? method }.values
    end
  end

end
