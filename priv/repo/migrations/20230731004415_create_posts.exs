defmodule Humbug.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :message, :text
      add :author_id, references(:users, on_delete: :nothing)
      add :topic_id, references(:topics, on_delete: :delete_all)

      timestamps()
    end

    create index(:posts, [:author_id])
    create index(:posts, [:topic_id])
  end
end
