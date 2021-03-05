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
      <div phx-hook="BeforeUnload" id="{{@game.id}}-{{@player_id}}">
        <p class="w3-xlarge">Game: {{@game.id}}</p>
        <Players game={{@game}} player_id = {{@player_id}}/>
        <ShareStart game={{@game}} :if={{@game.data.status == :new && @game.data.creator_id == @player_id}} />
        <p :if={{@game.data.status == :new && @game.data.creator_id != @player_id}} class="w3-panel w3-pale-yellow w3-border w3-padding">Waiting for the game creator to start the game</p>
        <GameOn game={{@game}} player_id = {{@player_id}} :if={{@game.data.status == :waiting_for_player}} />
        <GameOver game={{@game}} player_id = {{@player_id}} :if={{@game.data.status == :won}} />
      </div>
    """
  end

  def mount(_params, %{"game" => game, "player_id" => player_id}, socket) do
    game = %{game | data: Seka.parse(game.data)}
    if connected?(socket), do: Game.subscribe(game.id)
    {:ok, assign(socket, game: game, player_id: player_id)}
  end

  def handle_info({Game, :updated, updated_game}, socket = %{assigns: %{game: game}}) do
    game =
      (NaiveDateTime.compare(updated_game.updated_at, game.updated_at) in [:eq, :gt] &&
         updated_game) || game

    {:noreply, assign(socket, game: game)}
  end

  def handle_event("start", _params, socket = %{assigns: %{game: game}}) do
    game_data = Seka.start(game.data)

    {:noreply,
     assign(socket, game: (game.data != game_data && Game.update(game, game_data)) || game)}
  end

  def handle_event("restart", _params, socket = %{assigns: %{game: game}}) do
    game_data = Seka.restart(game.data)

    {:noreply,
     assign(socket, game: (game.data != game_data && Game.update(game, game_data)) || game)}
  end

  def handle_event(
        "draw_closed_deck",
        _params,
        socket = %{assigns: %{game: game, player_id: player_id}}
      ) do
    game_data = Seka.draw(game.data, player_id)

    {:noreply,
     assign(socket, game: (game.data != game_data && Game.update(game, game_data)) || game)}
  end

  def handle_event(
        "draw_discard_pile",
        _params,
        socket = %{assigns: %{game: game, player_id: player_id}}
      ) do
    game_data = Seka.draw(game.data, player_id, :discard_pile)

    {:noreply,
     assign(socket, game: (game.data != game_data && Game.update(game, game_data)) || game)}
  end

  def handle_event(
        "discard",
        %{"card" => card},
        socket = %{assigns: %{game: game, player_id: player_id}}
      ) do
    game_data = Seka.discard(game.data, player_id, card)

    {:noreply,
     assign(socket, game: (game.data != game_data && Game.update(game, game_data)) || game)}
  end

  def handle_event("sort", _params, socket = %{assigns: %{game: game, player_id: player_id}}) do
    game_data = Seka.sort(game.data, player_id)

    {:noreply,
     assign(socket, game: (game.data != game_data && Game.update(game, game_data)) || game)}
  end

  def handle_event("arrange", cards, socket = %{assigns: %{game: game, player_id: player_id}}) do
    game_data = Seka.arrange(game.data, player_id, cards)

    {:noreply,
     assign(socket, game: (game.data != game_data && Game.update(game, game_data)) || game)}
  end

  def handle_event("declare", _params, socket = %{assigns: %{game: game, player_id: player_id}}) do
    game_data = Seka.declare(game.data, player_id)

    {:noreply,
     assign(socket, game: (game.data != game_data && Game.update(game, game_data)) || game)}
  end
end
