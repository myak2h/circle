defmodule CircleWeb.Surface.Seka.Components.GameOver do
  use Surface.Component
  import Phoenix.HTML.Tag
  alias CircleWeb.Router.Helpers, as: Routes

  prop(game, :map)
  prop(player_id, :string)

  def render(assigns) do
    ~H"""
    <div>
      <div class="w3-large w3-pale-green w3-border w3-display-container w3-center w3-padding-24 w3-large">
        Game Over!  <button :if={{@player_id == @game.data.creator_id}} class="w3-button w3-round w3-blue w3-display-right w3-margin-right" phx-click="restart">Restart</button>
      </div>
      <hr>
      <div class="flex-row">
        {{ closed_deck(@game, @player_id) }}
        {{ @game.data.discard_pile != [] && discard_pile(@game, @player_id) || nil }}
      </div>
      <br/>
      <div :for={{{id, player} <- Enum.sort_by(@game.data.players, fn {id, _} -> id != @game.data.winner end)}}>
        <p class="w3-xlarge">{{player.name}} <b :if={{@game.data.winner == id}} class="w3-text-green"> - Winner!</b></p>
        <div class="flex-row">
          {{hand(player, @game.id)}}
        </div>
      </div>
      <br/>
      <hr>
    </div>
    """
  end

  defp hand(player, game_id) do
    for {card, index} <- Enum.with_index(player.hand[0]) do
      tag(:img,
        src: "#{card_image_path(card)}",
        style: "width: 100px; height: 140px; position: relative; left: #{-index * 40}px;",
        alt: card,
        id: "#{game_id}-#{player.id}-#{card}-#{index}",
        phx_hook: "ImageContextMenu"
      )
    end
  end

  defp discard_pile(game, player_id) do
    tag(:img,
      src: "#{game.data.discard_pile |> hd() |> card_image_path()}",
      alt: "discard pile",
      style: "width: 100px; height: 140px; position: relative; left: 20px",
      title: "Discard Pile",
      id: "discard_pile_#{game.id}_#{player_id}",
      phx_hook: "ImageContextMenu"
    )
  end

  defp closed_deck(game, player_id) do
    tag(:img,
      src: "#{card_image_path("BB")}",
      alt: "closed deck",
      style: "width: 100px; height: 140px;",
      title: "Closed Deck",
      id: "closed_deck_#{game.id}_#{player_id}",
      phx_hook: "ImageContextMenu"
    )
  end

  defp card_image_path(card) do
    Routes.static_path(CircleWeb.Endpoint, "/images/cards/") <> card <> ".svg"
  end
end
