# frozen_string_literal: true

class WebpushController < ApplicationController
  get '/' do
    @vapid = Notification.keys
    haml :'dashboard/webpush'
  end

  post '/subscribe' do
    if !find(params)
      NotificationSubscriber.create(params)
    end
  end

  post '/unsubscribe' do
    if notification_subscriber = find(params)
      notification_subscriber.destroy
    end
  end

  post '/' do
    Notification.send(params)
  end

  def find(params)
    NotificationSubscriber.find_by(auth: params['auth'])
  end
end
