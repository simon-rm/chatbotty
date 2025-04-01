class LLM::PromptService < ApplicationService
  def initialize(messages)
    @messages = messages
  end

  def call
    client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai_key,
      log_errors: true
    )
    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: formatted_messages,
        temperature: 0.7
      }
    )
    response_text = response.dig("choices", 0, "message", "content")
    response_text
  end

  private

  def formatted_messages
    return [ { role: :user, content: @messages } ] if @messages.is_a? String

    @messages.order(:id).map do |message|
      { role: message.human ? "user" : "assistant", content: message.text}
    end
  end
end