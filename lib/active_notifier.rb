require "active_notifier/version"

module ActiveNotifier
  extend ActiveSupport::Autoload

  autoload :Notification
  autoload :Notifier

  autoload :Messenger
  autoload :Caller

  autoload :MessageQueue
  autoload :Serialization

  module Clients
    autoload :SMS, 'active_notifier/clients/sms'
    autoload :Phone, 'active_notifier/clients/phone'
  end

  def notification_queue
    :normal
  end
end
