class AI::GenerateResponse
  include Interactor
  delegate :message, :response_message, to: :context
  def call
    generate_input_text_if_needed
    generate_response_message
    generate_response_audio_if_needed
  end

  after do
    context.message = response_message
  end

  private

  def generate_input_text_if_needed
    return if message.text?
    message.update text: OpenaiClient.audio_to_text(message.audio)
    context.fail!(error: "Could not convert audio to text") if message.text.blank?
  end

  def generate_response_message
    previous_response_id = message.user.last_response_id
    response = OpenaiClient.get_response(message.text, previous_response_id:)
    context.fail!(error: "could not get response") if response.blank?

    context.response_message = Message.new(**response, bot: true, user: message.user,
                                           platform: message.platform)
    context.fail!(error: response_message.errors.full_messages) unless response_message.save
  end

  def generate_response_audio_if_needed
    return if message.audio.blank?

    response_message.audio.attach OpenaiClient.text_to_audio(response_message.text)
    context.fail!(error: "Could not convert text to audio") if response_message.audio.blank?
  end

end
