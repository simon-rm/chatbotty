class AddOpenaiIdAndWaAudioIdToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :openai_response_id, :string
    add_column :messages, :wa_audio_id, :string
  end
end
