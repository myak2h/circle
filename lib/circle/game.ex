defmodule Circle.Game do
  use Ecto.Schema
  import Ecto.Changeset
  alias Circle.Repo

  schema "games" do
    field :data, :map
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
    Repo.get!(__MODULE__, id)
  end

  def update(game, data) do
    game
    |> changeset(%{data: data})
    |> Repo.update!()
  end
end
