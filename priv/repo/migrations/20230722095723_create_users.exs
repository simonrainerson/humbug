defmodule Humbug.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, size: 32

      timestamps()
    end
  end
end
