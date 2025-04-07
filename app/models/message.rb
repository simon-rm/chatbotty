class Message < ApplicationRecord
  enum :platform, %i[homepage whatsapp]

  belongs_to :user
  has_one_attached :audio

  validates :user, presence: true
end
