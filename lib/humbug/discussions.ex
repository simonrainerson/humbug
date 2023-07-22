defmodule Humbug.Discussions do
  @moduledoc """
  The Discussions context. This is the API for working with rooms and topics.
  """

  import Ecto.Query, warn: false
  alias Humbug.Repo

  alias Humbug.Discussions.{Room, RoomMembership}
  alias Humbug.Users.User

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_rooms do
    Repo.all(Room)
  end

  @doc """
  Returns a list of all rooms where user is a member.
  """
  def list_rooms_with_member(%User{} = user) do
    user
    |> Ecto.assoc(:rooms)
    |> Repo.all()
  end

  @doc """
  Returns a list of all rooms where user is the owner.
  """
  def list_rooms_with_owner(%User{} = user) do
    Room
    |> where(owner_id: ^user.id)
    |> Repo.all()
  end

  @doc """
  Returns a list of all rooms where user is a member or owner.
  """
  def list_rooms(%User{} = user) do
    (list_rooms_with_owner(user) ++ list_rooms_with_member(user)) |> Enum.uniq()
  end

  @doc """
  Add a user to a room, returns :ok if the user is already in the room.
  """
  def add_user_to_room(%Room{} = room, %User{} = user) do
    %RoomMembership{}
    |> RoomMembership.changeset(%{room_id: room.id, user_id: user.id})
    |> Repo.insert(on_conflict: :nothing)
  end

  @doc """
  Add a list of users to a room.
  """
  def add_users_to_room(%Room{} = room, users) do
    users
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), fn {user, index}, multi ->
      membership_changeset =
        %RoomMembership{}
        |> RoomMembership.changeset(%{room_id: room.id, user_id: user.id})

      Ecto.Multi.insert(multi, {:insert, index}, membership_changeset, on_conflict: :nothing)
    end)
    |> Repo.transaction()
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id), do: Repo.get!(Room, id)

  @doc """
  Find a room by name, returns nil if no such room exists.
  """
  def find_room(nil) do
    nil
  end

  def find_room(room_name) do
    Room
    |> where(name: ^room_name)
    |> Repo.one()
  end

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Update the banner of a room.
  """
  def update_banner(%Room{} = room, banner) do
    room
    |> Room.changeset(%{banner: banner})
    |> Repo.update()
  end

  @doc """
  Update the description of a room.
  """
  def update_description(%Room{} = room, description) do
    room
    |> Room.changeset(%{description: description})
    |> Repo.update()
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end
end
