defmodule Humbug.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :name, :string
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create table(:discussions) do
      add :room_id, references(:rooms, on_delete: :delete_all)
      add :topic_id, references(:topics, on_delete: :delete_all)

      timestamps()
    end

    create index(:topics, [:owner_id])
    create unique_index(:discussions, [:room_id, :topic_id])
  end
end
