defmodule Humbug.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string
      add :banner, :string
      add :description, :text
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create table(:room_memberships) do
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:room_id, references(:rooms, on_delete: :delete_all))

      timestamps()
    end

    create unique_index(:rooms, [:name])
    create index(:rooms, [:owner_id])
    create unique_index(:room_memberships, [:user_id, :room_id])
  end
end
