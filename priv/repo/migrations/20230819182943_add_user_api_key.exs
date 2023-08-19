defmodule Humbug.Repo.Migrations.AddUserApiKey do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :api_key, :uuid
    end
  end
end
