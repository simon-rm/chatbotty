class OpenaiClient
  CLIENT = OpenAI::Client.new
  class << self
    def audio_to_text(audio, model: "whisper-1")
      audio.open do |file|
        CLIENT.audio.transcribe(parameters: { model:, file: })["text"]
      end
    end

    def text_to_audio(text)
      audio_binary = CLIENT.audio.speech(parameters: {
        model: "tts-1",
        input: text,
        voice: "sage",
        response_format: "opus"
      })
      { filename: "audio.ogg", io: StringIO.new(audio_binary) }
    end

    def get_response(text, previous_response_id: nil, model: "gpt-3.5-turbo", temperature: 0.7)
      response = CLIENT.responses.create(parameters: { input: text, model:, temperature:,
                                                           previous_response_id: })
      { text: response.dig("output", 0, "content", 0, "text"), openai_response_id: response["id"] }
    end
  end
end