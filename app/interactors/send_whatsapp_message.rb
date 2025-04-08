class SendWhatsappMessage
  include Interactor
  WA_CLIENT = WhatsappSdk::Api::Client.new

  def call
    message = context.message
    sender_id = Rails.application.credentials.whatsapp.sender_id
    recipient_number = format_phone_number(message.user.phone_number)
    msg_data = if message.audio.attached?
      message.wa_audio_id = upload_audio(message, sender_id:)
      WA_CLIENT.messages.send_audio(sender_id:, recipient_number:,
                                    audio_id: message.wa_audio_id)
    else
      WA_CLIENT.messages.send_text(sender_id:, recipient_number:, message: message.text)
    end

    context.fail!(error: "Could not send whatsapp message") unless msg_data
    message.mid = msg_data.messages.first.id
    message.save
  end

  private

  def upload_audio(message, sender_id:)
    message.audio.open do |audio|
      WA_CLIENT.media.upload(sender_id:, file_path: audio.path,
                             type: message.audio.content_type)&.id
    end
  end

  # Converts argentine phone numbers to a format whatsapp API understands
  def format_phone_number(phone_number)
    phone = Phonelib.parse(phone_number)
    if phone.country == "AR"
      "#{phone.country_code}#{phone.national(false).delete_prefix("0")}"
    else
      phone.sanitized
    end
  end
end
