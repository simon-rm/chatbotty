class SendWhatsappMessage
  include Interactor

  def call
    message = context.message
    wa_client = WhatsappSdk::Api::Client.new
    msg_data = wa_client.messages.send_text(
      sender_id: Rails.application.credentials.whatsapp.sender_id,
      recipient_number: format_phone_number(message.user.phone_number),
      message: message.text,
    )
    context.fail!(error: "Could not send whatsapp message") unless msg_data
    context.message.update(mid: msg_data.messages.first.id)
  end

  private

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