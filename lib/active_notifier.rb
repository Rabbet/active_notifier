require 'active_support'
require "active_notifier/version"
require 'globalid'

module ActiveNotifier
  extend ActiveSupport::Autoload

  autoload :Notification
  autoload :Notifier

  autoload :Messenger
  autoload :Caller

  autoload :MessageQueue

  module Clients
    autoload :SMS, 'active_notifier/clients/sms'
    autoload :Phone, 'active_notifier/clients/phone'
  end

  def notification_queue
    :normal
  end
end
