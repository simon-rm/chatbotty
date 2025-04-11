class WhatsappClient
  CLIENT = WhatsappSdk::Api::Client.new
  SENDER_ID = Rails.application.credentials.whatsapp.sender_id
  class << self
    def send_text(text, recipient_number:)
      CLIENT.messages.send_text(sender_id: SENDER_ID, recipient_number:, message: text)
            .messages.first.id
    end

    def send_audio(audio_id, recipient_number:)
      CLIENT.messages.send_audio(sender_id: SENDER_ID, recipient_number:, audio_id:)
            .messages.first.id
    end

    def download_file(media_id:, attach_to:)
      file_info = CLIENT.media.get(media_id:)
      extension = Mime::Type.lookup(file_info.mime_type).ref.to_s

      Tempfile.create([ "media", extension ]) do |file|
        CLIENT.media.download(url: file_info.url, file_path: file.path,
                                        media_type: file_info.mime_type)
        attach_to.attach(io: file, filename: "#{media_id}.#{extension}", content_type: file_info.mime_type)
      end
    end

    def upload_file(file)
      file.open do |f|
        type = Marcel::MimeType.for(f)
        CLIENT.media.upload(sender_id: SENDER_ID, file_path: f.path, type:).id
      end
    end
  end
end