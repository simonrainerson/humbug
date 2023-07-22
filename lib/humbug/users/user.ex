defmodule Humbug.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Humbug.Discussions.Room

  schema "users" do
    field :name, :string
    many_to_many :rooms, Room, join_through: "room_memberships"

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 32)
  end
end
