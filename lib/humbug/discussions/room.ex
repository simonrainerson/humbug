defmodule Humbug.Discussions.Room do
  use Ecto.Schema
  import Ecto.Changeset
  alias Humbug.Discussions.{Discussion, RoomMembership, Topic}
  alias Humbug.Users.User

  schema "rooms" do
    field :name, :string
    belongs_to(:owner, User)
    many_to_many(:members, User, join_through: RoomMembership)
    field :banner, :string
    field :description, :string
    many_to_many :topics, Topic, join_through: Discussion

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :owner_id, :banner, :description])
    |> validate_required([:name, :owner_id])
    |> unique_constraint(:name)
  end
end

defmodule Humbug.Discussions.RoomMembership do
  use Ecto.Schema
  import Ecto.Changeset
  alias Humbug.{Discussions.Room, Users.User}

  schema "room_memberships" do
    belongs_to(:user, User)
    belongs_to(:room, Room)

    timestamps()
  end

  @doc false
  def changeset(room_membership, attrs) do
    room_membership
    |> cast(attrs, [:user_id, :room_id])
    |> validate_required([:room_id, :user_id])
    |> unique_constraint([:user, :room])
  end
end
