defmodule CircleWeb.Live.Components.Seka.GameOn do
  use Phoenix.LiveComponent
  import Phoenix.HTML.Tag, only: [tag: 2]
  import CircleWeb.SekaLive, only: [card_image_path: 1]
  alias CircleWeb.Live.Components.Seka.DropZone
  alias CircleWeb.Live.Components.Seka.GameOver

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
      <div style="display: flex; flex-flow: row; padding-left: 50px;">
        <%= if @game.data.discard_pile != [] do %>
          <div>
            <div style="padding-left: 20px">discard pile</div>
            <%=  discard_pile(@game) %>
          </div>
        <% end %>
        <div>
          <div style="padding-left: 20px">closed deck</div>
          <%= closed_deck(@game) %>
        </div>
      </div>
      <br>
      <div>
        <%= if @game.data.status == :won do %>
          <%= live_component @socket, GameOver, game: @game, player_id: @player_id %>
        <% else %>
          <%= live_component @socket, DropZone,
                  cards: @game.data.players[@player_id].hand[0],
                  player_id: @player_id,
                  player_name: "You",
                  drop_zone_id: "drop_zone_#{@player_id}",
                  title: @game.data.players[@player_id].name,
                  color: "white",
                  game_status: @game.data.status,
                  winner: @game.data.winner %>
        <% end %>
      </div>
    """
  end

  defp discard_pile(game) do
    tag(:img,
      src: "#{game.data.discard_pile |> hd() |> card_image_path()}",
      style: "margin: 5px; #{(game.data.status == :won && "pointer-events: none") || ""}",
      phx_click: "draw_discard_pile",
      alt: "closed deck",
      width: 100,
      height: 150
    )
  end

  defp closed_deck(game) do
    tag(:img,
      src: "#{card_image_path("BB")}",
      style: "margin: 5px; #{(game.data.status == :won && "pointer-events: none") || ""}",
      phx_click: "draw_closed_deck",
      alt: "closed deck",
      width: 100,
      height: 150
    )
  end
end
