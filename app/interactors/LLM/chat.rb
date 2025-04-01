class LLM::Chat
  include Interactor

  def call
    conversation = Conversation.where(updated_at: 8.hours.ago..)
                               .find_or_initialize_by(session_id: context.session_id)
    message = Message.new(human: true, text: context.message_text, conversation:)
    unless message.save
      context.fail!(error: message.errors.full_messages)
      return
    end

    response = LLM::PromptService.call(conversation.messages)

    bot_message = Message.new(human: false, text: response, conversation:)
    if bot_message.save
      context.response = bot_message.text
    else
      context.fail!(error: bot_message.errors.full_messages)
    end
  end
end