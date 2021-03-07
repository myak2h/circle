defmodule Circle.Repo.Migrations.UseUuid do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add(:data, :map)
      timestamps()
    end
  end
end
