defmodule CircleWeb.Surface.Seka.Game do
  use Surface.LiveView
  alias Circle.Chat
  alias Circle.Game
  alias Circle.Games.Seka
  alias CircleWeb.Surface.Seka.Components.Players
  alias CircleWeb.Surface.Seka.Components.ShareStart
  alias CircleWeb.Surface.Seka.Components.GameOn
  alias CircleWeb.Surface.Seka.Components.GameOver
  alias CircleWeb.Router.Helpers, as: Routes
  alias CircleWeb.Surface.Seka.Components.Chat, as: ChatComponent

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
        <ChatComponent :if={{@game.data.status in [:waiting_for_player, :won]}} game={{@game}} player_id = {{@player_id}} />
      </div>
    """
  end

  def mount(_params, %{"game" => game, "player_id" => player_id}, socket) do
    game = %{game | data: Seka.parse(game.data)}
    if connected?(socket), do: Game.subscribe(game.id)
    {:ok, assign(socket, game: game, player_id: player_id)}
  end

  def handle_info(:updated, socket = %{assigns: %{game: game}}) do
    {:noreply, assign(socket, game: refresh(game))}
  end

  def handle_event("start", _params, socket = %{assigns: %{game: game}}) do
    game_data = Seka.start(game.data)
    game.data != game_data && Game.update(game, game_data)

    {:noreply, socket}
  end

  def handle_event("restart", _params, socket = %{assigns: %{game: game}}) do
    game_data = Seka.restart(game.data)
    game.data != game_data && Game.update(game, game_data)
    {:noreply, socket}
  end

  def handle_event(
        "draw_closed_deck",
        _params,
        socket = %{assigns: %{game: game, player_id: player_id}}
      ) do
    game_data = Seka.draw(game.data, player_id)
    game.data != game_data && Game.update(game, game_data)
    {:noreply, socket}
  end

  def handle_event(
        "draw_discard_pile",
        _params,
        socket = %{assigns: %{game: game, player_id: player_id}}
      ) do
    game_data = Seka.draw(game.data, player_id, :discard_pile)
    game.data != game_data && Game.update(game, game_data)

    {:noreply, socket}
  end

  def handle_event(
        "discard",
        %{"card" => card},
        socket = %{assigns: %{game: game, player_id: player_id}}
      ) do
    game_data = Seka.discard(game.data, player_id, card)

    game.data != game_data && Game.update(game, game_data)

    {:noreply, socket}
  end

  def handle_event("sort", _params, socket = %{assigns: %{game: game, player_id: player_id}}) do
    game_data = Seka.sort(game.data, player_id)

    game.data != game_data && Game.update(game, game_data)
    {:noreply, socket}
  end

  def handle_event("arrange", cards, socket = %{assigns: %{game: game, player_id: player_id}}) do
    game_data = Seka.arrange(game.data, player_id, cards)

    game.data != game_data && Game.update(game, game_data)

    {:noreply, socket}
  end

  def handle_event("declare", _params, socket = %{assigns: %{game: game, player_id: player_id}}) do
    game_data = Seka.declare(game.data, player_id)

    game.data != game_data && Game.update(game, game_data)

    {:noreply, socket}
  end

  def handle_event(
        "send_message",
        %{"chat" => %{"message" => message}},
        socket = %{assigns: %{game: game, player_id: player_id}}
      ) do
    Chat.create(%{message: message, sender: player_id, game_id: game.id})
    {:noreply, socket}
  end

  defp refresh(game) do
    game = Game.get(game.id)
    %Game{game | data: Seka.parse(game.data)}
  end
end
