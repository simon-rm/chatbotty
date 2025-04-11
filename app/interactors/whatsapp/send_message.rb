class Whatsapp::SendMessage
  include Interactor
  delegate :message, to: :context


  def call
    upload_audio_if_needed
    send_message
  end

  private

  def upload_audio_if_needed
    return if message.audio.blank? || message.wa_audio_id?

    message.update(wa_audio_id: WhatsappClient.upload_file(message.audio))
    context.fail!(error: "Could not upload audio") if message.wa_audio_id.blank?
  end

  def send_message
    recipient_number = format_phone_number(message.user.phone_number)
    
    message.mid = if message.wa_audio_id?
                     WhatsappClient.send_audio(message.wa_audio_id, recipient_number:)
                   elsif message.text?
                     WhatsappClient.send_text(message.text, recipient_number:)
                   else
                     context.fail!(error: "No text or audio attached")
                   end

    context.fail!(error: "Could not send whatsapp message") if message.mid.blank?
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