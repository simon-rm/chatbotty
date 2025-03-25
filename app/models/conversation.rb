class Conversation < ApplicationRecord
  has_many :messages

  def formatted_messages
    messages.order(:id).map do |message|
      { role: message.human ? "user" : "assistant", content: message.text}
    end
  end
end
