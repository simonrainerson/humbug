defmodule Humbug.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Humbug.Discussions.Room

  schema "users" do
    field(:name, :string)
    field(:api_key, :binary_id)
    many_to_many(:rooms, Room, join_through: "room_memberships")

    timestamps()
  end

  defp generate_api_key(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{api_key: _}} -> changeset
      %Ecto.Changeset{valid?: true} -> changeset |> put_change(:api_key, Ecto.UUID.generate())
      _ -> changeset
    end
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> generate_api_key()
    |> validate_required([:name, :api_key])
    |> validate_length(:name, max: 32)
  end
end
