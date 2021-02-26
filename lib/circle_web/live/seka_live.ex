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
      <%= if @game.data.status == :won do %>
        The game is over!
      <% end %>
      <div style="display: flex; flex-flow: row;">
        <div>
          <h3>Players</h3>
          <hr>
          <%= live_component @socket, DropZone,
            cards: @game.data.players[@player_id].hand[0],
            player_id: @player_id,
            player_name: "You",
            drop_zone_id: "drop_zone_#{@player_id}",
            title: @game.data.players[@player_id].name,
            color: "white",
            game_status: @game.data.status,
            winner: @game.data.winner %>
          <hr>
          <%= if @game.data.status == :won do %>
            <%= for {id, player} <- @game.data.players, id != @player_id do %>
              <%= live_component @socket, DropZone,
                cards: @game.data.players[id].hand[0],
                player_id: id,
                player_name: player.name,
                drop_zone_id: "drop_zone_#{id}",
                title: @game.data.players[id].name,
                game_status: :won,
                winner: @game.data.winner,
                color: "white" %>
            <% end %>
          <% else %>
            <%= for {id, player} <- @game.data.players, id != @player_id do %>
              <p>👤 - <%= player.name %></p>
            <% end %>
          <% end %>
          <hr>
        </div>
        <div style="margin-left: 20px; padding-left: 20px;">
          <h3>Discard Pile</h3>
          <hr>
          <%= if @game.data.discard_pile == [] do %>
            <p>__</p>
          <% else %>
            <%= tag :img,
              src: "#{@game.data.discard_pile |> hd() |> card_image_path()}",
              style: "margin: 5px; #{@game.data.status == :won && "pointer-events: none" || ""}",
              phx_click: "draw_discard_pile",
              alt: "closed deck",
              width: 100,
              height: 150 %>
          <% end %>
          <h3>Closed Deck</h3>
          <hr>
          <div style="display: flex; flex-flow: row;">
            <%= tag :img,
                src: "#{card_image_path("BB")}",
                style: "margin: 5px; #{@game.data.status == :won && "pointer-events: none" || ""}",
                phx_click: "draw_closed_deck",
                alt: "closed deck",
                width: 100,
                height: 150%>
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

  def handle_event(
        "draw_closed_deck",
        _params,
        socket = %{assigns: %{game: game, player_id: player_id}}
      ) do
    game = Game.get(game.id)
    game_data = game.data |> Seka.parse() |> Seka.draw(player_id)
    game = Game.update(game, game_data)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event(
        "draw_discard_pile",
        _params,
        socket = %{assigns: %{game: game, player_id: player_id}}
      ) do
    game = Game.get(game.id)
    game_data = game.data |> Seka.parse() |> Seka.draw(player_id, :discard_pile)
    game = Game.update(game, game_data)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event(
        "discard",
        %{"card" => card},
        socket = %{assigns: %{game: game, player_id: player_id}}
      ) do
    game = Game.get(game.id)
    game_data = game.data |> Seka.parse() |> Seka.discard(player_id, card)
    game = Game.update(game, game_data)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("sort", _params, socket = %{assigns: %{game: game, player_id: player_id}}) do
    game = Game.get(game.id)
    game_data = game.data |> Seka.parse() |> Seka.sort(player_id)
    game = Game.update(game, game_data)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("arrange", cards, socket = %{assigns: %{game: game, player_id: player_id}}) do
    game = Game.get(game.id)
    game_data = game.data |> Seka.parse() |> Seka.arrange(player_id, cards)
    game = Game.update(game, game_data)
    {:noreply, assign(socket, game: game)}
  end

  def handle_event("declare", _params, socket = %{assigns: %{game: game, player_id: player_id}}) do
    game = Game.get(game.id)
    game_data = game.data |> Seka.parse() |> Seka.declare(player_id)
    game = Game.update(game, game_data)
    {:noreply, assign(socket, game: game)}
  end

  def handle_info({Game, :updated, game}, socket) do
    {:noreply, assign(socket, game: game)}
  end

  def card_image_path(card) do
    Routes.static_path(CircleWeb.Endpoint, "/images/cards/") <> card <> ".svg"
  end

  def card("JO"), do: "JO"

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
