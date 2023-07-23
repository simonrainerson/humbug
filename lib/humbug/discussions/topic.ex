defmodule Humbug.Discussions.Topic do
  use Ecto.Schema
  import Ecto.Changeset
  alias Humbug.Users.User
  alias Humbug.Discussions.{Discussion, Room}

  schema "topics" do
    field :name, :string
    belongs_to :owner, User
    many_to_many :rooms, Room, join_through: Discussion

    timestamps()
  end

  defp update_rooms(changeset, attrs) do
    if Map.has_key?(attrs, :rooms) do
      put_assoc(changeset, :rooms, attrs.rooms)
    else
      changeset
    end
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:name, :owner_id])
    |> validate_required([:name, :owner_id])
    |> update_rooms(attrs)
  end
end

defmodule Humbug.Discussions.Discussion do
  use Ecto.Schema
  import Ecto.Changeset
  alias Humbug.Discussions.{Room, Topic}

  schema "discussions" do
    belongs_to :room, Room
    belongs_to :topic, Topic

    timestamps()
  end

  @doc false
  def changeset(discussion, attrs) do
    discussion
    |> cast(attrs, [:room_id, :topic_id])
    |> validate_required([:room_id, :topic_id])
    |> unique_constraint([:room_id, :topic_id])
  end
end
