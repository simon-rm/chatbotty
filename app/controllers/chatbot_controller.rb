class ChatbotController < ApplicationController
  def show; end
  def respond
    user = User.find_or_create_by(session_id: session.id.cookie_value)
    result = LLM::Chat.call(message_attributes: { text: params[:message_text] }, user:)
    if result.success?
      render json: { status: "success", response: result.message.text }, status: :created
    else
      render json: { status: "error", error: result.error }, status: :unprocessable_entity
    end
  end
end
