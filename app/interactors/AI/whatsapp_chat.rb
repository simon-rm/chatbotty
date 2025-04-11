class AI::WhatsappChat
  include Interactor::Organizer

  organize StoreMessage, Whatsapp::DownloadAudio, AI::GenerateResponse,
           Whatsapp::SendMessage
end
