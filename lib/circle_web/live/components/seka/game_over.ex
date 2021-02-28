defmodule CircleWeb.Live.Components.Seka.GameOver do
  use Phoenix.LiveComponent
  import Phoenix.HTML.Tag
  import CircleWeb.SekaLive, only: [card_image_path: 1]

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    IO.inspect(assigns.game)

    ~L"""

      <div>
        <div style="position: relative;  display: flex; flex-flow: row;">
          <div style="position: relative; width: 150px; min-width: 150px; height: 20px; border-right: solid 1px; text-align: center">Tris</div>
          <div style="position: relative; width: 150px; min-width: 150px; height: 20px; border-right: solid 1px; text-align: center">Tris</div>
          <div style="position: relative; width: 200px; min-width: 200px; height: 20px; border-right: solid 1px; text-align: center">Quatris</div>
        </div>
        <%= for {id, player} <- sort_by_winner(@game.data.players, @game.data.winner) do %>
          <div style="margin-left: 200px; margin: 20px; font-size: 20px">
            <%= player.name %>
            <%= if @game.data.winner ==  id do %>
              - <b style="color: green;">Winner!</b>
            <% end %>
          </div>
          <div style="margin-top: 10px; margin-left: 0px; display: flex;">
            <%= for {card, index} <- Enum.with_index(player.hand[0]) do %>
              <%= tag :img,
                src: "#{card_image_path(card)}",
                style: "position: relative; left: #{- index * 50}px;",
                alt: card,
                width: 100,
                height: 150%>
            <% end %>
          </div>
        <% end %>
      </div>
    """
  end

  defp sort_by_winner(players, winner) do
    Enum.sort_by(players, fn {id, _player} -> id == winner end, :desc)
  end
end
