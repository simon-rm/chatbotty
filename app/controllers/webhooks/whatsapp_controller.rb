class Webhooks::WhatsappController < ApplicationController
  def respond
    user = User.find_or_create_by(phone_number: user_attributes[:phone_number])
    user.update(user_attributes)
    Rails.logger.info(user_attributes.merge(message_attributes).to_s)
    LLM::WhatsappChat.call(message_attributes:, user:)
  end

  private

  def user_attributes
    {
      name: whatsapp_attributes.dig("contacts", 0, "profile", "name"),
      phone_number: whatsapp_attributes.dig("contacts", 0, "wa_id")
    }
  end

  def message_attributes
    {
      text: whatsapp_attributes.dig("messages", 0, "text", "body"),
      mid: whatsapp_attributes.dig("messages", 0, "id"),
      platform: :whatsapp
    }
  end

  def whatsapp_attributes
    params.dig("entry", 0, "changes", 0, "value")
  end
end