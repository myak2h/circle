defmodule CircleWeb.Live.Components.Seka.GameHeader do
  use Phoenix.LiveComponent
  alias CircleWeb.Live.Components.Seka.GameStatus

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
      <p style="font-size: 20px;">Game: <%= @game.id %></p>
      <div style="display: flex; flex-flow: row;">
        <div style="margin-right: 10px; font-size: 20px">Players: </div>
        <%= for {id, player} <- @game.data.players do %>
            <div style="margin-right: 10px; font-size: 20px; color: <%= color(id, @game) %>"><%= player.name %></div>
        <% end %>
      </div>
      <br>
      <%= live_component @socket, GameStatus, game: @game, player_id: @player_id %>
    """
  end

  defp color(player_id, %{data: %{turn: player_id}}), do: "blue"
  defp color(_player_id, _game), do: "black"
end
