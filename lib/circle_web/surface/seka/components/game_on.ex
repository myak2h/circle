defmodule CircleWeb.Surface.Seka.Components.GameOn do
  use Surface.Component
  import Phoenix.HTML.Tag
  alias CircleWeb.Router.Helpers, as: Routes

  prop(game, :map)
  prop(player_id, :string)

  def render(assigns) do
    ~H"""
      <div>
        <p class="w3-panel w3-pale-blue w3-border w3-padding">
          Waiting for
          <b>{{@game.data.turn == @player_id && "you" || @game.data.players[@game.data.turn].name}}</b>
          to <b>{{@game.data.next_action}}</b> ...
        </p>
        <hr>
        <div class="flex-row">
          {{ closed_deck(@game) }}
          {{ @game.data.discard_pile != [] && discard_pile(@game) || nil }}
        </div>
        <br/><br/>
        <div id="<%= @drop_zone_id %>" phx-hook="Drag" class="flex-row">
          {{hand(@game, @player_id)}}
        </div>
        <br/><br/>
        <div class="flex-row">
          <button class="w3-button w3-blue w3-large w3-round" phx-click="sort">Sort</button>
          <button class="w3-margin-left w3-button w3-green w3-round w3-large" phx-click="declare">Declare</button>
        </div>
        <hr>
        <b class="w3-large">How to play the game ?</b>
        <ul class="w3-medium">
          <li>You can <b>draw</b> a card by clicking on either the <b>closed deck</b> or the <b>discard pile</b> in the middle.</li>
          <li>You can <b>discard</b> a card by clicking on one of the cards in your hand.</li>
          <li>The purpose of the game is to build <b>two trises</b> and <b>a quatris</b>.</li>
          <li>a <b>tris</b> is a set of <b>3</b> cards of either the same number and different sign or consecutive number and the same sign. a <b>quatris</b> is similar to a tris but with <b>4</b> cards.</li>
          <li>The <b>Jocker</b> card can be used in place of any card</li>
          <li>Use the <b>Sort</b> button to sort the cards</li>
          <li>Put the two trises at the beginning, then the quatris at the end and click on the <b>Declare</b> button to finish the game.</li>
        </ul>
      </div>
    """
  end

  defp hand(game, player_id) do
    for {card, index} <- Enum.with_index(game.data.players[player_id].hand[0]) do
      tag(:img,
        src: "#{card_image_path(card)}",
        draggable: "true",
        class: "draggable",
        id: "#{player_id}-card-#{index}",
        style: "width: 100px; height: 140px; position: relative; left: #{-index * 50}px;",
        phx_click: "discard",
        phx_value_card: card,
        alt: card,
        phx_hook: "ImageContextMenu"
      )
    end
  end

  defp discard_pile(game) do
    tag(:img,
      src: "#{game.data.discard_pile |> hd() |> card_image_path()}",
      phx_click: "draw_discard_pile",
      alt: "discard pile",
      style: "width: 100px; height: 140px; position: relative; left: 20px",
      title: "Discard Pile",
      phx_hook: "ImageContextMenu"
    )
  end

  defp closed_deck(game) do
    tag(:img,
      src: "#{card_image_path("BB")}",
      phx_click: "draw_closed_deck",
      alt: "closed deck",
      style: "width: 100px; height: 140px;",
      title: "Closed Deck",
      phx_hook: "ImageContextMenu"
    )
  end

  defp card_image_path(card) do
    Routes.static_path(CircleWeb.Endpoint, "/images/cards/") <> card <> ".svg"
  end
end
