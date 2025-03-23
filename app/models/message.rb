class Message < ApplicationRecord
  belongs_to :conversation

  validates :text, :conversation, presence: true
end
