require "rails_helper"

RSpec.describe Chatbot::Chat do
  let!(:params) { {message_text: "Hello!", session_id: "123"} }

  describe ".call" do
    context "Success" do
      let!(:result) { Chatbot::Chat.call(params) }

      it "is successful" do
        expect(result).to be_success
      end

      it "creates a human message" do
        msg = Message.find_by(text: params[:message_text])
        expect(msg).to be_present
      end

      it "creates a bot message" do
        msg = Message.find_by(human: false)
        expect(msg).to be_present
      end

      context "Starting a new conversation" do
        it "creates a conversation" do
          expect(Conversation.count).to eq(1)
        end
      end

      context "Continuing a conversation" do
        before do
          Chatbot::Chat.call(params)
        end

        it "does not create a new conversation" do
          expect(Conversation.count).to eq(1)
        end
      end
    end

    context "Failure" do
      context "Prompt is blank" do
        let!(:result) { Chatbot::Chat.call(message_text: nil) }

        it "is not successful" do
          expect(result).not_to be_success
        end
      end
    end
  end
end
