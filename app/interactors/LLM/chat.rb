class LLM::Chat
  include Interactor

  def call
    user = context.user
    incoming_message = Message.new(user:, **context.message_attributes)
    if incoming_message.wa_audio_id?
      wa_client = WhatsappSdk::Api::Client.new
      audio_info = wa_client.media.get(media_id: incoming_message.wa_audio_id)
      Tempfile.create(%w[audio .ogg]) do |audio|
        wa_client.media.download(url: audio_info.url, file_path: audio.path,
                                 media_type: audio_info.mime_type)
        incoming_message.text = audio_to_text(audio)
        incoming_message.save
        incoming_message.audio.attach(io: audio, filename: audio.path,
                                      content_type: audio_info.mime_type)
      end
    end
    unless incoming_message.save
      context.fail!(error: incoming_message.errors.full_messages)
      return
    end
    previous_response_id = user.messages.where(bot: true).last&.openai_response_id
    response = get_response(incoming_message.text, previous_response_id:)

    context.message = Message.new(**response, bot: true, user:, platform: incoming_message.platform)
    if incoming_message.audio.attached?
      context.message.audio = text_to_audio(context.message.text)
    end
    context.fail!(error: context.message.errors.full_messages) unless context.message.save
  end

  private

  def audio_to_text(audio)
    text = OpenAI::Client.new.audio.transcribe(parameters: {
      model: "whisper-1",
      file: audio
    })["text"]
    audio.rewind
    text
  end

  def text_to_audio(text)
    audio_binary = OpenAI::Client.new.audio.speech(parameters: {
      model: "tts-1",
      input: text,
      voice: "sage",
      response_format: "opus"
    })
    { filename: "audio.ogg", io: StringIO.new(audio_binary) }
  end

  def get_response(input, previous_response_id: nil, model: "gpt-3.5-turbo", temperature: 0.7)
    response = OpenAI::Client.new.responses.create(parameters: { model:, input:, temperature:,
                                                                 previous_response_id: })
    { text: response.dig("output", 0, "content", 0, "text"), openai_response_id: response["id"]  }
  end
end