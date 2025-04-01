require "rails_helper"

RSpec.describe 'LLM::PromptService' do
  let!(:messages) { [Message.new(human: true, text: "Whats 2+3?")] }
  let!(:conversation) { Conversation.create(messages:) }

  context "when input is messages relation" do
    let(:result) { LLM::PromptService.call(conversation.messages) }
    it 'is successful' do
      expect(result.present?).to be true
    end
  end

  context "when input is string input" do
    let(:result) { LLM::PromptService.call("Whats 2+3?") }
    it 'is successful' do
      expect(result.present?).to be true
    end
  end
end
