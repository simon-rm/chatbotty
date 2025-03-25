import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["messages", "input", "submit"];

  connect() {
    this.i = 0;
    this.initializeScrollbar();
    this.setupInitialMessage();
  }

  initializeScrollbar() {
    // Handle scrollbar initialization manually without jQuery
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight;
  }

  setupInitialMessage() {
    setTimeout(() => {
      this.botMessage('Hi there, I\'m Sophie. How can I help you?');
    }, 100);
  }

  updateScrollbar() {
    // Update the scroll position to always scroll to the bottom
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight;
  }

  setDate() {
    this.d = new Date();
    if (this.m !== this.d.getMinutes()) {
      this.m = this.d.getMinutes();

      // Create timestamp and checkmarks using HTML strings
      const timestamp = `<div class="timestamp">${this.d.getHours()}:${this.m}</div>
                         <div class="checkmark-sent-delivered">✔</div>
                         <div class="checkmark-read">✔</div>`;

      // Append elements to the last message
      this.messagesTarget.lastElementChild.insertAdjacentHTML('beforeend', timestamp);
    }
  }


  insertMessage() {
    const msg = this.inputTarget.value;
    if (msg.trim() === '') {
      return false;
    }

    // Create the new personal message
    const message = `<div class="message message-personal">${msg}</div>`
    this.messagesTarget.insertAdjacentHTML('beforeend', message);

    this.setDate();
    this.inputTarget.value = '';
    this.updateScrollbar();

    setTimeout(() => {
      this.botMessage();
    }, 1000 + Math.random() * 20 * 100);
  }

  botMessage(text = null) {
// Create and append the loading message
    const loadingMessage = `
  <div class="message loading new">
    <figure class="avatar">
      <img src="http://askavenue.com/img/17.jpg">
    </figure>
    <span></span>
  </div>
`;
    this.messagesTarget.insertAdjacentHTML('beforeend', loadingMessage);
    this.updateScrollbar();


    if (text) {
      setTimeout(() => {
        this.insertBotMessage(text)
      }, 1000 + Math.random() * 2000);
    }
    else {
      const msg = Array.from(document.querySelectorAll('.message-personal')).at(-1);
      this.getLlmResponse(msg.innerText);
    }

  }

  insertBotMessage(text) {
    this.messagesTarget.lastElementChild.remove();

    // Create and append the fake message
    const message = `
      <div class="message new">
        <figure class="avatar">
          <img src="http://askavenue.com/img/17.jpg">
        </figure>
        ${text}
      </div>
    `;
    this.messagesTarget.insertAdjacentHTML('beforeend', message);

    this.setDate();
    this.updateScrollbar();
    this.i++;
  }

  //also inserts response
  async getLlmResponse(prompt) {
    try {
      console.log(prompt);
      const response = await fetch(`${window.location.origin}/messages`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message_text: prompt,
        }),
      });

      const data = await response.json();
      this.insertBotMessage(data.response)
    } catch (error) {
      console.error('Error:', error);
    }
  }

  sendMessage() {
    this.insertMessage();
  }

  // Event handlers for button click or keydown
  onSubmitClick() {
    this.sendMessage();
  }

  onEnterKey(e) {
    if (e.key === 'Enter') {
      this.sendMessage();
      e.preventDefault();
    }
  }
}
