class ActiveNotifier::Notification
  def initialize(event, event_options, *args)
    @event = event
    @event_options = event_options
    @args = args
    @using = @event_options[:methods].values
    @to = @event_options[:to]
  end

  def using(*methods)
    self.tap do
      @using = @event_options[:methods].select { |method, _| methods.include? method }.values
    end
  end

  def to(obj_or_array)
    self.tap do
      @to = obj_or_array
    end
  end

  def deliver_later(options = {})
    notification_classes.each { |klass| klass.deliver_later(options) }
  end

  def deliver(options = {})
    notification_classes.each { |klass| klass.deliver(options) }
  end

  private
  def notification_classes
    if @to.respond_to?(:map)
      @to.map { |to| notification_classes_for(receiver) }.flatten
    else
      notification_classes_for(@to)
    end
  end

  def notification_classes_for(to)
    @using.map do |notification_class|
      notification_class.send(@event, *@args)
    end
  end
end
