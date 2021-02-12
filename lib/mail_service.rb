require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

class MailService
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'fifa_autotrader'.freeze
  CREDENTIALS_PATH = './config/client_secrets.json'.freeze
  TOKEN_PATH = ENV['GMAIL_TOKEN_PATH'].freeze
  SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_MODIFY
  USER_ID = 'me'

  def authorize
    client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
    token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
    authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
    user_id = 'default'
    credentials = authorizer.get_credentials user_id
    if credentials.nil?
      url = authorizer.get_authorization_url base_url: OOB_URI
      puts 'Open the following URL in the browser and enter the ' \
        'resulting code after authorization:\n' + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end

  def gmail_service
    @gmail_service ||=
      begin
        service = Google::Apis::GmailV1::GmailService.new
        service.client_options.application_name = APPLICATION_NAME
        service.authorization = authorize
        service
      end
  end

  def security_code
    messages = gmail_service.list_user_messages(
      USER_ID, q:"from:'ea@e.ea.com' subject:'código de segurança' label:unread"
    ).messages

    if messages
      message_id = messages.first.id
      message_detail = gmail_service.get_user_message(USER_ID, message_id)
      delete_message(message_id)
      security_code = message_detail.snippet.
        match(/código de segurança da EA: (\d{6})/)[1]
    end
  end

  def self.security_code
    new.security_code
  end

  private

  def delete_message(message_id)
    mtr = Google::Apis::GmailV1::ModifyThreadRequest.new(
      remove_label_ids: ['UNREAD'])
    gmail_service.modify_message(USER_ID, message_id, mtr)
    gmail_service.trash_user_message(USER_ID, message_id)
  end
end
