class LLM::WhatsappChat
  include Interactor::Organizer

  organize LLM::Chat, SendWhatsappMessage
end