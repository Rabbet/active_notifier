class ActiveNotifier::NotificationJob < ActiveJob::Base
  queue_as ActiveNotifier.notification_queue

  def perform(klass, method, *args)
    klass.constantize.send(method, *args).deliver
  end
end
