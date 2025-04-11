class Message < ApplicationRecord
  enum :platform, %i[homepage whatsapp]

  belongs_to :user
  has_one_attached :audio

  validate :has_content

  def has_content
    if [text, audio, wa_audio_id].all?(&:blank?)
      errors.add(:message, "must have text, audio or wa_audio_id")
    end
  end
end
