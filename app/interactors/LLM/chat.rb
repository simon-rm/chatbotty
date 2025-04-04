class LLM::Chat
  include Interactor

  def call
    user = context.user
    incoming_message = Message.new(user:, **context.message_attributes)
    unless incoming_message.save
      context.fail!(error: incoming_message.errors.full_messages)
      return
    end

    response = LLM::PromptService.call(user.messages)

    context.message = Message.new(bot: true, text: response,
                                  user:, platform: incoming_message.platform)

    context.fail!(error: context.message.errors.full_messages) unless context.message.save
  end
end