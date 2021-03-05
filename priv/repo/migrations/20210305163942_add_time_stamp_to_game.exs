defmodule Circle.Repo.Migrations.AddTimeStampToGame do
  use Ecto.Migration

  def change do
    drop(table(:games))

    create table(:games) do
      add(:data, :map)
      timestamps()
    end
  end
end
