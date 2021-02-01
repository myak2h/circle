defmodule CircleWeb.SekaLive do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Circle.Game
  alias Circle.Games.Seka

  def render(assigns) do
    ~L"""
    <p>Game: <%= @game.id %></p>
    <%= if @game.data.status == :new do%>
    <%= if @game.data.creator_id == @player_id do %>
    <button phx-click="start">Start game</button>
    <% end %>
    <h3>Players: </h3>
    <div class="row">
      <%= for {_id, player} <- @game.data.players do %>
      <div class="column">
        <h3>👤 - <%= player.name %></h3>
      </div>
      <% end %>
    </div>
    <% else %>
    <div class="row">
      <div class="column">
        <div class="row">
        <%= for {id, player} <- @game.data.players, id != @player_id do %>
          <div class="column">
            <h3>👤 - <%= player.name %></h3>
            <h1 style="font-size: 48px;">🂠</h1>
          </div>
        <% end %>
        </div>
        <hr>
        <h3>👤 - <%= @game.data.players[@player_id].name %></h3>
        <div class="row">
        <%= for card <- @game.data.players[@player_id].hand[0] do %>
          <div class="column" style="padding: 5px;" ondrop="drop(event)" ondragover="allowDrop(event)">
            <div draggable="true" ondragstart="drag(event)" style="background-color: white; padding: 3px; border-style: solid; border-width: thin;"><%= card %></div>
          </div>
        <% end %>
        </div>
      </div>
      <div class="column column-offset-10" style="border-left-style: groove;">
        <h3>Draw</h3>
        <div class="row">
          <div class="column column-offset-10">
            <h1 style="font-size: 48px;">🂠</h1>
          </div>
          <div class="column">
            <div draggable="true" ondragstart="drag(event)" style="background-color: white; padding: 3px; border-style: solid; border-width: thin; width: 32px; height: 38px; margin-top: 14px"><%= List.last(@game.data.closed_deck) %></div>
          </div>
        </div>
        <br>
        <h3>Discard</h3>
          <h1><%= @game.data.discard_pile != [] && hd(@game.data.discard_pile) || "__"%></h1>
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
