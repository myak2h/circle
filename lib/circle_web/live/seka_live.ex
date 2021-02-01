defmodule CircleWeb.SekaLive do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Circle.Game
  alias Circle.Games.Seka

  def render(assigns) do
    ~L"""
    <p>Game: <%= @game.id %></p>
    <p>Player: <%= @player_id %></p>
    <%= if @game.data.status == :new and @game.data.creator_id == @player_id do%>
    <button phx-click="start">Start game</button>
    <% end %>
    <pre>
      <code>
          <%= inspect(@game, pretty: true) %>
      </code>
    </pre>
    """
  end

  def mount(_params, %{"game" => game, "player_id" => player_id}, socket) do
    game = %{game | data: Seka.parse(game.data)}
    if connected?(socket), do: Game.subscribe(game.id)
    {:ok, assign(socket, game: show(game, player_id), player_id: player_id)}
  end

  def handle_event("start", _params, socket = %{assigns: %{game: game, player_id: player_id}}) do
    game = Game.get(game.id)
    game_data = game.data |> Seka.parse() |> Seka.start()
    game = Game.update(game, game_data)
    {:noreply, assign(socket, game: show(game, player_id))}
  end

  def handle_info({Game, :updated, game}, socket = %{assigns: %{player_id: player_id}}) do
    {:noreply, assign(socket, game: show(game, player_id))}
  end

  defp show(
         game = %{data: %{closed_deck: closed_deck, discard_pile: discard_pile, players: players}},
         player_id
       ) do
    closed_deck = List.duplicate("▮", length(closed_deck) - 1) ++ [List.last(closed_deck)]

    discard_pile =
      case discard_pile do
        [] -> []
        [shown_card | other_cards] -> [shown_card | List.duplicate("▮", length(other_cards))]
      end

    players =
      Enum.into(players, %{}, fn
        {^player_id, player} ->
          {player_id, player}

        {other_player_id, other_player} ->
          hand =
            Enum.into(other_player.hand, %{}, fn {index, set} ->
              {index, List.duplicate("▮", length(set))}
            end)

          {other_player_id, %{other_player | hand: hand}}
      end)

    %{
      game
      | data: %{
          game.data
          | closed_deck: closed_deck,
            discard_pile: discard_pile,
            players: players
        }
    }
  end
end
