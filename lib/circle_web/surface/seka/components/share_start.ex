defmodule CircleWeb.Surface.Seka.Components.ShareStart do
  use Surface.Component
  alias CircleWeb.Router.Helpers, as: Routes

  prop(game, :map)

  def render(assigns) do
    ~H"""
      <p class="w3-panel w3-pale-yellow w3-border w3-padding">Copy and share the game link below to add players</p>
      <div class="w3-raw">
        <input class="w3-input w3-col s8 m6" value="{{Routes.seka_url(@socket, :show, @game.id)}}" readonly id="game-link"/>
        <button phx-hook="CopyToClipboard" class="w3-button w3-border"><i class="fas fa-clipboard"></i></button>
      </div>
      <button class="w3-button w3-margin-top w3-blue w3-round w3-large" :on-click="start" :attrs={{disabled: @game.data.players |> Map.keys() |> length() < 2}}>Start</button>
    """
  end
end
