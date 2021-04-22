# frozen_string_literal: true

require 'webpush'

class Notification
  def self.keys
    unless Setting.get('vapid_private_key')
      vapid_key = Webpush.generate_key
      %w[public_key private_key].each do |item|
        Setting.create!(key: "vapid_#{item}", value: vapid_key.send(item), secure: 1, group: 'Notifications')
      end
    end

    {
      public_key: Setting.get('vapid_public_key'),
      private_key: Setting.get('vapid_private_key')
    }
  end

  def self.send_all(title, description)
    NotificationSubscriber.all.each do |subscriber|
      send(subscriber.attributes, { title: title, description: description }.to_json)
    end
  end

  def self.send(params, message)
    Webpush.payload_send(
      message: message,
      endpoint: params['endpoint'],
      p256dh: params['p256dh'],
      auth: params['auth'],
      vapid: keys.merge(expiration: 60*60*12)
    )
  end
end
