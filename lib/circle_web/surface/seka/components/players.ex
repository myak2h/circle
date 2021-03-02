defmodule CircleWeb.Surface.Seka.Components.Players do
  use Surface.Component
  prop(game, :map)
  prop(player_id, :string)

  def render(assigns) do
    ~H"""
      <div class="w3-margin-top w3-margin-bottom flex-row">
        <div class="w3-xlarge">Players: </div>
        <div :for={{{id, player} <- @game.data.players}}
            class="w3-xlarge w3-border-left w3-margin-left {{@game.data.turn == id && "w3-text-indigo" || ""}}"
            style="padding-left: 20px">
          <b>{{player.name}}</b>
          <i class="w3-medium">{{id == @player_id && "(you)" || nil}}</i>
          <i class="w3-medium">{{id == @game.data.creator_id && "(creator)" || nil}}</i>
        </div>
      </div>
    """
  end
end
