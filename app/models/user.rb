class User < ApplicationRecord
  has_many :messages

  def last_response_id
    messages.where(bot: true).last&.openai_response_id
  end
end
