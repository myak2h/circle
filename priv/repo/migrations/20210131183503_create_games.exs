defmodule Circle.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :data, :map
    end
  end
end
