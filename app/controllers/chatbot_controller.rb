class ChatbotController < ApplicationController

  def show; end
  def respond
    result = LLM::Chat.call(message_text: params[:message_text], session_id: session.id.cookie_value)
    if result.success?
      render json: { status: 'success', response: result.response }, status: :created
    else
      render json: { status: 'error', error: result.error }, status: :unprocessable_entity
    end
  end

  def whatsapp_webhook
    render plain: params['hub.challenge']
  end
end
