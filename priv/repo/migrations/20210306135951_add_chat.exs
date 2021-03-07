defmodule Circle.Repo.Migrations.AddChat do
  use Ecto.Migration

  def change do
    create table(:chats, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :message, :string
      add :sender, :string
      add :game_id, references(:games, type: :uuid)
      timestamps()
    end
  end
end
