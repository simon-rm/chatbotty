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
  # It deletes non-digits, removes the 9 after the national code and adds a 15 after the area code
  # E.g 5491134567890 -> 54111534567890
  def format_phone_number(phone_number)
    phone_number.gsub!(/\D/, "")
    is_argentine = phone_number.starts_with? "54"
    contains_fifteen = phone_number.length >= 14

    return phone_number unless is_argentine

    phone_number.sub!(/^549/, "54")

    if contains_fifteen
      phone_number
    else
      possible_area_codes = [phone_number[2..5], phone_number[2..4], phone_number[2..3]]
      area_code = possible_area_codes.find do |possible_area_code|
        CONSTANTS::AR_AREA_CODES.find { it == possible_area_code }
      end
      phone_number.insert(area_code.length + 2, "15")
    end
  end
end