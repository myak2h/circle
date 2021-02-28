defmodule CircleWeb.SekaLive do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Circle.Game
  alias Circle.Games.Seka
  alias CircleWeb.Router.Helpers, as: Routes
  alias CircleWeb.Live.Components.Seka.GameRule
  alias CircleWeb.Live.Components.Seka.GameHeader
  alias CircleWeb.Live.Components.Seka.GameOn

  def render(assigns) do
    ~L"""
    <div>
      <%= live_component @socket, GameHeader, game: @game, player_id: @player_id %>
      <br><br>
      <div style="display: flex; flex-wrap: wrap">
        <div style="width: 50%; min-width: 600px">
          <%= if @game.data.status != :new do%>
            <%= live_component @socket, GameOn, game: @game, player_id: @player_id %>
          <% end %>
        </div>
        <div style="width: 30%; min-width: 400px">
          <%= live_component @socket, GameRule %>
        </div>
      </div>
    <div>
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
