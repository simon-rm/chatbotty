class Chatbot::Chat
  include Interactor

  def call
    conversation = Conversation.where(updated_at: 8.hours.ago..)
                               .find_or_initialize_by(session_id: context.session_id)
    message = Message.new(human: true, text: context.message_text, conversation:)
    unless message.save
      context.fail!(error: message.errors.full_messages)
      return
    end
    client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai_key,
      log_errors: true
    )
    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: message.text}],
        temperature: 0.7,
      }
    )
    response_text = response.dig("choices", 0, "message", "content")
    bot_message = Message.new(human: false, text: response_text, conversation:)
    if bot_message.save
      context.response = bot_message.text
    else
      context.fail!(error: bot_message.errors.full_messages)
    end
  end
end