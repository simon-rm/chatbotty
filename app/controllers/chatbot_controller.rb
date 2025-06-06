class ChatbotController < ApplicationController
  def show; end
  def respond
    result = AI::Chat.call(message_attributes:, user_attributes:)

    if result.success?
      render json: { status: "success", response: result.message.text }, status: :created
    else
      render json: { status: "error", error: result.error }, status: :unprocessable_entity
    end
  end

  def whatsapp_webhook
    render plain: params['hub.challenge']
  end

  private

  def message_attributes
    {
      text: params[:message_text],
    }
  end

  def user_attributes
    {
      session_id: session.id.cookie_value,
    }
  end
end
