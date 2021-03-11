# frozen_string_literal: true

class NotificationSubscriber < ActiveRecord::Base
  validates_presence_of :endpoint, :p256dh, :auth
end
