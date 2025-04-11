class AI::Chat
  include Interactor::Organizer

  organize StoreMessage, AI::GenerateResponse
end