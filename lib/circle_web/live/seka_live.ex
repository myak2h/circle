defmodule CircleWeb.SekaLive do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Circle.Game
  alias Circle.Games.Seka
  alias CircleWeb.Router.Helpers, as: Routes
  alias CircleWeb.Live.Components.GameLink
  alias CircleWeb.Live.Components.DropZone

  def render(assigns) do
    ~L"""
    <p>Game: <%= @game.id %></p>
    <%= if @game.data.status == :new do%>
      <%= if @game.data.creator_id == @player_id do %>
        <%= live_component @socket, GameLink, link: Routes.seka_url(@socket, :show, @game.id) %><br>
        <button phx-click="start">Start Game</button>
      <% else %>
        <p>Waiting for creator to start the game...<p>
      <% end %>
      <h3>Players</h3>
      <%= for {id, player} <- @game.data.players do %>
        <p>
          👤 -
          <%= if id == @player_id do%>
            You
          <% else %>
            <%= player.name %>
          <% end %>
        </p>
      <% end %>
    <% else %>
      <%= if @game.data.status == :waiting_for_player do %>
        <i>
          Waiting for
          <b>
            <%= if @game.data.turn == @player_id do%>
              you
            <% else %>
              <%= @game.data.players[@game.data.turn].name %>
            <% end %>
          </b>
          to
          <b><%= @game.data.next_action%></b>...</i>
      <% end %>
      <div style="display: flex; flex-flow: row;">
        <div>
          <h3>Players</h3>
          <%= live_component @socket, DropZone,
            cards: @game.data.players[@player_id].hand[0],
            player_id: @player_id,
            drop_zone_id: "drop_zone_#{@player_id}",
            title: @game.data.players[@player_id].name,
            color: "white" %>

          <%= for {id, player} <- @game.data.players, id != @player_id do %>
            <p>👤 - <%= player.name %></p>
          <% end %>
        </div>
        <div style="margin-left: 20px; padding-left: 20px;">
          <h3>Discard Pile</h3>
          <%= if @game.data.discard_pile == [] do %>
            <p>__</p>
          <% else %>
            <button
              style="padding: 5px; margin: 5px; font-size: 20px"
              phx-click="draw_discard_pile">
              <%= @game.data.discard_pile |> hd() |> card() %>
            </button>
          <% end %>
          <h3>Closed Deck</h3>
          <div style="display: flex; flex-flow: row;">
            <button style="background-color: black; width: 40px; height: 40px; padding: 5px; margin: 5px" phx-click="draw_closed_deck"></button>
            <button style="padding: 5px; margin: 5px; font-size: 20px"><%= @game.data.closed_deck |> List.last() |> card() %></button>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  def mount(_params, %{"game" => game, "player_id" => player_id}, socket) do
    game = %{game | data: Seka.parse(game.data)}
    if connected?(socket), do: Game.subscribe(game.id)
    {:ok, assign(socket, game: game, player_id: player_id)}
  end

  def handle_event("start", _params, socket = %{assigns: %{game: game}}) do
    game = Game.get(game.id)
    game_data = game.data |> Seka.parse() |> Seka.start()
    game = Game.update(game, game_data)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("draw_closed_deck", _params, socket = %{assigns: %{game: game, player_id: player_id}}) do
    game = Game.get(game.id)
    game_data = game.data |> Seka.parse() |> Seka.draw(player_id)
    game = Game.update(game, game_data)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("draw_discard_pile", _params, socket = %{assigns: %{game: game, player_id: player_id}}) do
    game = Game.get(game.id)
    game_data = game.data |> Seka.parse() |> Seka.draw(player_id, :discard_pile)
    game = Game.update(game, game_data)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("discard", %{"card" => card}, socket = %{assigns: %{game: game, player_id: player_id}}) do
    game = Game.get(game.id)
    game_data = game.data |> Seka.parse() |> Seka.discard(player_id, card)
    game = Game.update(game, game_data)
    {:noreply, assign(socket, game: game)}
  end

  def handle_info({Game, :updated, game}, socket) do
    {:noreply, assign(socket, game: game)}
  end

  def card("JO"), do: "🃟"
  def card(card) do
    [value, sign] = String.split(card, "", trim: true)
    value(value) <> sign(sign)
  end

  defp value("T"), do: "10"
  defp value(value), do: value

  defp sign("S"), do: "♠"
  defp sign("H"), do: "♥"
  defp sign("D"), do: "⬥"
  defp sign("F"), do: "✿"
end
