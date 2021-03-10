# frozen_string_literal: true

require 'webpush'

get '/webpush' do
  unless Setting.get('vapid_private_key')
    vapid_key = Webpush.generate_key
    %w[public_key private_key].each do |item|
      Setting.create!(key: "vapid_#{item}", value: vapid_key.send(item), secure: 1)
    end
  end

  @vapid = {
    public_key: Setting.get('vapid_public_key'),
    private_key: Setting.get('vapid_private_key')
  }

  haml :'dashboard/webpush'
end

post '/webpush' do
  Webpush.payload_send(
    message: params['message_json'],
    endpoint: params['endpoint'],
    p256dh: params['p256dh'],
    auth: params['auth'],
    vapid: {
      public_key: Setting.get('vapid_public_key'),
      private_key: Setting.get('vapid_private_key')
    }
  )
end
