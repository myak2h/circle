defmodule Circle.Games.Seka do
  @moduledoc """
  Seka keeps the contexts that define the domain
  and business logic for Seka game.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Circle.Games.Seka.Deck
  alias Circle.Games.Seka.Player
  @derive Jason.Encoder
  defstruct players: %{},
            status: :new,
            closed_deck: [],
            discard_pile: [],
            turn: nil,
            creator_id: nil,
            next_action: nil,
            winner: nil

  def parse(game) do
    players =
      Enum.into(game["players"], %{}, fn {player_id, player} ->
        {player_id, Player.parse(player)}
      end)

    %__MODULE__{
      players: players,
      status: String.to_atom(game["status"]),
      closed_deck: game["closed_deck"],
      discard_pile: game["discard_pile"],
      turn: game["turn"],
      creator_id: game["creator_id"],
      next_action: game["next_action"],
      winner: game["winner"]
    }
  end

  def new(creator) do
    creator_id = Ecto.UUID.generate()
    creator = %Player{name: creator, id: creator_id}
    {creator_id, %__MODULE__{players: %{creator_id => creator}, creator_id: creator_id}}
  end

  def add_player(game = %{players: players, status: :new}, player_name) do
    player_index = players |> Map.keys() |> length()
    player_id = Ecto.UUID.generate()
    player = %Player{name: player_name, id: player_id, index: player_index}
    players = Map.put(players, player_id, player)
    {player_id, %__MODULE__{game | players: players}}
  end

  def start(game = %{players: players, status: :new}) do
    cards = Deck.cards()

    {[{starter_id, starter} | other_players], [start_card | cards]} =
      Enum.map_reduce(players, cards, fn {id, player}, acc ->
        {player_cards, cards_left} = Enum.split(acc, 10)
        hand = Map.put(player.hand, 0, player_cards)
        {{id, %{player | hand: hand}}, cards_left}
      end)

    starter_set1 = Map.get(starter.hand, 0)

    starter_hand = Map.put(starter.hand, 0, [start_card | starter_set1])

    players =
      Enum.into(
        [{starter_id, %{starter | hand: starter_hand}} | other_players],
        %{}
      )

    %__MODULE__{
      game
      | closed_deck: cards,
        players: players,
        status: :waiting_for_player,
        next_action: :discard,
        turn: starter_id
    }
  end
end
