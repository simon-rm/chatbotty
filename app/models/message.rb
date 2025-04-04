class Message < ApplicationRecord
  enum :platform, %i[homepage whatsapp]

  belongs_to :user

  validates :text, :user, presence: true
end
