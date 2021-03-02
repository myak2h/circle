defmodule CircleWeb.Surface.Seka.Components.GameOver do
  use Surface.Component
  import Phoenix.HTML.Tag
  alias CircleWeb.Router.Helpers, as: Routes

  prop(game, :map)
  prop(player_id, :string)

  def render(assigns) do
    ~H"""
    <div>
      <p class="w3-panel w3-pale-green w3-border w3-padding">
        Game Over!
      </p>
      <hr>
      <div class="flex-row">
        {{ closed_deck(@game) }}
        {{ @game.data.discard_pile != [] && discard_pile(@game) || nil }}
      </div>
      <br/>
      <div :for={{{id, player} <- Enum.sort_by(@game.data.players, fn {id, _} -> id != @game.data.winner end)}}>
        <p class="w3-xlarge">{{player.name}} <b :if={{@game.data.winner == id}} class="w3-text-green"> - Winner!</b></p>
        <div class="flex-row">
          {{hand(player.hand[0])}}
        </div>
      </div>
      <br/>
      <hr>
    </div>
    """
  end

  defp hand(cards) do
    for {card, index} <- Enum.with_index(cards) do
      tag(:img,
        src: "#{card_image_path(card)}",
        style: "width: 100px; height: 140px; position: relative; left: #{-index * 40}px;",
        alt: card
      )
    end
  end

  defp discard_pile(game) do
    tag(:img,
      src: "#{game.data.discard_pile |> hd() |> card_image_path()}",
      alt: "discard pile",
      style: "width: 100px; height: 140px; position: relative; left: 20px",
      title: "Discard Pile"
    )
  end

  defp closed_deck(game) do
    tag(:img,
      src: "#{card_image_path("BB")}",
      alt: "closed deck",
      style: "width: 100px; height: 140px;",
      title: "Closed Deck"
    )
  end

  defp card_image_path(card) do
    Routes.static_path(CircleWeb.Endpoint, "/images/cards/") <> card <> ".svg"
  end
end
