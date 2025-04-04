class Webhooks::WhatsappController < ApplicationController
  def respond
    user = User.find_or_create_by(wa_id: user_attributes[:wa_id])
    user.update(user_attributes)
    Rails.logger.info(user_attributes.merge(message_attributes).to_s)
    LLM::WhatsappChat.call(message_attributes:, user:)
  end

  private

  def user_attributes
    {
      name: params.dig("value", "contacts", "profile", "name"),
      phone_number: params.dig("value", "metadata", "phone_number_id"),
      wa_id: params.dig("value", "contacts", "wa_id")
    }
  end

  def message_attributes
    {
      text: params.dig("value", "messages", "text", "body"),
      mid: params.dig("value", "messages", "id"),
      platform: :whatsapp
    }
  end
end