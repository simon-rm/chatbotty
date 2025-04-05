require 'rails_helper'

RSpec.describe SendWhatsappMessage do
  let(:user) { User.create!(phone_number: '5491134567890', name: 'Test User') }
  let(:message) { Message.create!(text: 'Hello', user:) }
  let(:whatsapp_client) { instance_double(WhatsappSdk::Api::Client, messages: messages_double ) }
  let(:messages_double) { double(:messages) }
  
  before do
    allow(WhatsappSdk::Api::Client).to receive(:new).and_return(whatsapp_client)
  end

  context 'when WhatsApp API succeeds' do
    before do
      api_response = double(messages: [double(id: 'whatsapp_msg_id')])
      allow(messages_double).to receive(:send_text).and_return(api_response)
    end

    it 'succeeds' do
      result = described_class.call(message:)
      expect(result).to be_a_success
    end

    it 'updates message id' do
      described_class.call(message:)
      expect(message.reload.mid).to eq('whatsapp_msg_id')
    end
  end

  context 'when WhatsApp API fails' do
    before do
      allow(messages_double).to receive(:send_text).and_return(nil)
    end

    it 'fails' do
      result = described_class.call(message:)
      expect(result).to be_a_failure
    end

    it 'does not update message id' do
      described_class.call(message:)
      expect(message.reload.mid).to be_nil
    end
  end
end