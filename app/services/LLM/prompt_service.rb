class LLM::PromptService < ApplicationService
  def initialize(messages)
    @messages = messages
  end

  def call
    response = OpenAI::Client.new.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: formatted_messages,
        temperature: 0.7
      }
    )
    response.dig("choices", 0, "message", "content")
  end

  private

  def formatted_messages
    return [ { role: :user, content: @messages } ] if @messages.is_a? String

    @messages.order(:id).map do |message|
      { role: message.bot ? "assistant" : "user", content: message.text}
    end
  end
end