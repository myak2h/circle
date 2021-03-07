defmodule CircleWeb.Surface.Seka.Components.Chat do
  use Surface.Component
  alias CircleWeb.Router.Helpers, as: Routes
  alias Surface.Components.Form
  alias Surface.Components.Form.Field
  alias Surface.Components.Form.TextArea
  prop(game, :map)
  prop(player_id, :string)

  def render(assigns) do
    ~H"""
    <button id="{{@game.id}}_{{@player_id}}_open_chat_button" phx-hook="OpenChatButton" class="open-button w3-button w3-teal w3-xlarge w3-round w3-bar">
      <span class="w3-margin">Chat</span>
      <i class="far fa-comment"></i>
    </button>
    <div class="chat-popup" id="chatForm">
      <Form for={{ :chat }}  submit="send_message" opts={{ autocomplete: "off", class: "form-container" }}>
        <div class="w3-xlarge">Chat</div>
        <span id="{{@game.id}}_{{@player_id}}_close_chat_button" phx-hook="CloseChatButton" class="w3-button w3-button w3-display-topright">X</span>
        <div class="w3-leftbar w3-margin-top w3-margin-bottom">
          <div id="{{@game.id}}_{{@player_id}}_chat_messages" style="max-height: 300px; overflow: scroll" phx-hook="ChatMessages" class="w3-margin-top" >
            <div :for={{chat <- @game.chats}} class="w3-card w3-margin w3-light-grey w3-padding">
              <p class="w3-margin-bottom">{{chat.message}}</p>
              <div class="w3-row">
                <span class="w3-right"><b>{{@game.data.players[chat.sender].name}}</b></span>
              </div>
            </div>
          </div>
        </div>
        <TextArea field="message" opts={{required: true, placeholder: "Type message..", rows: 2}} rows="2"/>
        <button type="submit" class="w3-button w3-teal w3-large" style="width: 100%">Send</button>
      </Form>
    </div>
    """
  end
end
