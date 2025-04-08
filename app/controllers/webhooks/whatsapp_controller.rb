class Webhooks::WhatsappController < ApplicationController
  def respond
    if whatsapp_params["messages"]
      user = User.find_or_create_by(phone_number: user_attributes[:phone_number])
      user.update(user_attributes)
      result = LLM::WhatsappChat.call(message_attributes:, user:)
      if result.success?
        head :ok
      else
        render json: { error: result.error }, status: :internal_server_error # generic error
      end
    end
  end

  private

  def user_attributes
    {
      name: whatsapp_params.dig("contacts", 0, "profile", "name"),
      phone_number: whatsapp_params.dig("contacts", 0, "wa_id")
    }
  end

  def message_attributes
    {
      text: whatsapp_params.dig("messages", 0, "text", "body"),
      mid: whatsapp_params.dig("messages", 0, "id"),
      wa_audio_id: whatsapp_params.dig("messages", 0, "audio", "id"),
      platform: :whatsapp
    }
  end

  def whatsapp_params
    params.dig("entry", 0, "changes", 0, "value")
  end
end
