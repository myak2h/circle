defmodule Circle.Game do
  use Circle.Schema
  import Ecto.Changeset
  alias Circle.Chat
  alias Circle.Repo

  @topic inspect(__MODULE__)

  schema "games" do
    field(:data, :map)
    has_many(:chats, Chat)
    timestamps()
  end

  def changeset(%__MODULE__{} = game, attrs) do
    game
    |> cast(attrs, [:data])
    |> validate_required([:data])
  end

  def new(data) do
    %__MODULE__{}
    |> changeset(%{data: data})
    |> Repo.insert!()
  end

  def get(id) do
    __MODULE__
    |> Repo.get!(id)
    |> Repo.preload(:chats)
  end

  def update(game, data) do
    game
    |> changeset(%{data: data})
    |> Repo.update!()
    |> notify_subscribers(:updated)
  end

  # def subscribe do
  #   Phoenix.PubSub.subscribe(Circle.PubSub, @topic)
  # end

  def subscribe(game_id) do
    Phoenix.PubSub.subscribe(Circle.PubSub, "game:#{game_id}")
  end

  defp notify_subscribers(game, event) do
    Phoenix.PubSub.broadcast(Circle.PubSub, "game:#{game.id}",  event)
    game
  end
end
