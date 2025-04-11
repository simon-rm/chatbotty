class Whatsapp::DownloadAudio
  include Interactor
  def call
    message = context.message
    return if message.wa_audio_id.blank?

    WhatsappClient.download_file(media_id: message.wa_audio_id, attach_to: message.audio)
    context.fail!(error: "Could not download audio") if message.audio.blank?
  end
end