defmodule CircleWeb.SekaLive do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Circle.Game
  alias Circle.Games.Seka
  alias CircleWeb.Router.Helpers, as: Routes
  alias CircleWeb.Live.Components.GameLink

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
      <%= for {_id, player} <- @game.data.players do %>
        <p>👤 - <%= player.name %></p>
      <% end %>
    <% else %>
      <div style="display: flex; flex-flow: row;">
        <div>
          <h3>Players</h3>
          <p>👤 - <%= @game.data.players[@player_id].name %></p>
          <div style="display: flex; flex-flow: row;">
            <%= for card <- @game.data.players[@player_id].hand[0] do %>
              <div style="border-width: thin; border-style: dotted; padding: 5px; margin: 3px; width: 30px; height: 30px;" ondrop="drop(event)" ondragover="allowDrop(event)">
                <div draggable="true" ondragstart="drag(event)" style="border-style: solid; border-width: thin; padding: 4px;"><%= card %></div>
              </div>
            <% end %>
          </div>
          <%= for {id, player} <- @game.data.players, id != @player_id do %>
            <p>👤 - <%= player.name %></p>
            <div style="border-width: thin; border-style: dotted; padding: 5px; margin: 3px; width: 30px; height: 30px;">
              <div style="width: 30px; height: 30px; background-color: black;"></div>
            </div>
          <% end %>
        </div>
        <div style="margin-left: 20px; padding-left: 20px;">
          <h3>Discard Pile</h3>
          <p><%= @game.data.discard_pile != [] && hd(@game.data.discard_pile) || "__"%></p>
          <h3>Closed Deck</h3>
          <div style="display: flex; flex-flow: row;">
            <div style="border-width: thin; border-style: dotted; padding: 5px; margin: 3px; width: 30px; height: 30px;">
              <div style="width: 30px; height: 30px; background-color: black;"></div>
            </div>
            <div style="border-width: thin; border-style: dotted; padding: 5px; margin: 3px; width: 30px; height: 30px;" ondrop="drop(event)" ondragover="allowDrop(event)">
              <div draggable="true" ondragstart="drag(event)" style="border-style: solid; border-width: thin; padding: 4px;"><%= List.last(@game.data.closed_deck) %></div>
            </div>
          </div>
        </div>
      </div>



    <% end %>
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

  defp show(game = %{data: %{status: :new}}, _player_id), do: game

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
              {index, List.duplicate("🂠", length(set))}
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
