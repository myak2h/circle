defmodule Circle.Chat do
  use Circle.Schema
  import Ecto.Changeset
  alias Circle.Game
  alias Circle.Repo

  schema "chats" do
    field(:message, :string)
    field(:sender, :string)
    belongs_to(:game, Game)
    timestamps()
  end

  def changeset(%__MODULE__{} = chat, attrs) do
    chat
    |> cast(attrs, [:message, :sender, :game_id])
    |> validate_required([:message, :sender, :game_id])
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
    |> notify()
  end

  defp notify(chat) do
    Phoenix.PubSub.broadcast(Circle.PubSub, "game:#{chat.game_id}", :updated)
    chat
  end
end
