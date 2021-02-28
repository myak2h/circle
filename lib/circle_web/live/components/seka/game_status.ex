defmodule CircleWeb.Live.Components.Seka.GameStatus do
  use Phoenix.LiveComponent
  alias CircleWeb.Live.Components.GameLink
  alias CircleWeb.Router.Helpers, as: Routes

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <%= if @game.data.status == :new do%>
      <%= if @game.data.creator_id == @player_id do %>
        <%= live_component @socket, GameLink, link: Routes.seka_url(@socket, :show, @game.id) %><br>
        <button phx-click="start">Start Game</button>
      <% else %>
        <i>Waiting for creator to start the game...<i>
      <% end %>
    <% end %>

    <%= if @game.data.status == :waiting_for_player do %>
      <i>
        Waiting for
        <b><%= @game.data.players[@game.data.turn].name %></b>
        to
        <b><%= @game.data.next_action%></b>
        ...
      <i>
    <% end %>

    <%= if @game.data.status == :won do %>
      <i>The game is over!</i>
    <% end %>
    """
  end
end
