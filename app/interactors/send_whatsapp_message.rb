class SendWhatsappMessage
  include Interactor
  WA_CLIENT = WhatsappSdk::Api::Client.new

  def call
    message = context.message
    msg_data = WA_CLIENT.messages.send_text(
      sender_id: Rails.application.credentials.whatsapp.sender_id,
      recipient_number: message.user.phone_number,
      message: message.text,
    )
    context.fail!(error: "Could not send whatsapp message") unless msg_data
    context.message.update(mid: msg_data.messages.first.id)
  end
end