defmodule CircleWeb.Surface.Seka.Game do
  use Surface.LiveView
  alias Circle.Game
  alias Circle.Games.Seka
  alias CircleWeb.Surface.Seka.Components.Players
  alias CircleWeb.Surface.Seka.Components.ShareStart
  alias CircleWeb.Surface.Seka.Components.GameOn
  alias CircleWeb.Surface.Seka.Components.GameOver
  alias CircleWeb.Router.Helpers, as: Routes

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <p class="w3-xlarge">Game: {{@game.id}}</p>
      <Players game={{@game}} player_id = {{@player_id}}/>
      <ShareStart game={{@game}} :if={{@game.data.status == :new && @game.data.creator_id == @player_id}} />
      <p :if={{@game.data.status == :new && @game.data.creator_id != @player_id}} class="w3-panel w3-pale-yellow w3-border w3-padding">Waiting for the game creator to start the game</p>
      <GameOn game={{@game}} player_id = {{@player_id}} :if={{@game.data.status == :waiting_for_player}} />
      <GameOver game={{@game}} player_id = {{@player_id}} :if={{@game.data.status == :won}} />
    """
  end

  def mount(_params, %{"game" => game, "player_id" => player_id}, socket) do
    game = %{game | data: Seka.parse(game.data)}
    if connected?(socket), do: Game.subscribe(game.id)
    {:ok, assign(socket, game: game, player_id: player_id)}
  end

  def handle_info({Game, :updated, game}, socket) do
    {:noreply, assign(socket, game: game)}
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
end
