defmodule Humbug.Discussions do
  @moduledoc """
  The Discussions context. This is the API for working with rooms and topics.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
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
  Creates a room with a topic Chat.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(attrs \\ %{}) do
    Multi.new()
    |> Multi.run(
      :topic,
      fn _repo, _changes -> create_topic(attrs |> Map.put(:name, "Chat")) end
    )
    |> Multi.run(
      :room,
      fn repo, %{topic: topic} ->
        %Room{topics: [topic]}
        |> Room.changeset(attrs)
        |> repo.insert()
      end
    )
    |> Repo.transaction()
    |> case do
      {:ok, changes} -> {:ok, changes.room}
      {:error, _failed_operation, failed_value, _changes_so_far} -> {:error, failed_value}
    end
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

  alias Humbug.Discussions.Topic

  @doc """
  Returns the list of topics.

  ## Examples

      iex> list_topics()
      [%Topic{}, ...]

  """
  def list_topics do
    Repo.all(Topic)
  end

  def list_topics(nil) do
    []
  end

  def list_topics(%Room{} = room) do
    room
    |> Ecto.assoc(:topics)
    |> Repo.all()
  end

  @doc """
  Gets a single topic.

  Raises `Ecto.NoResultsError` if the Topic does not exist.

  ## Examples

      iex> get_topic!(123)
      %Topic{}

      iex> get_topic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_topic!(id), do: Repo.get!(Topic, id)

  @doc """
  Find all topics with name, and if given, belonging to a room.
  """
  def find_topics(nil) do
    nil
  end

  def find_topics(topic_name) do
    Topic |> where(name: ^topic_name) |> Repo.all()
  end

  def find_topics(_, nil) do
    []
  end

  def find_topics(nil, _) do
    []
  end

  def find_topics(topic_name, in_room) do
    Repo.all(
      from topic in Topic,
        where: topic.name == ^topic_name,
        preload: :rooms,
        join: room in assoc(topic, :rooms),
        on: room.id == ^in_room.id
    )
  end

  @doc """
  Creates a topic.

  ## Examples

      iex> create_topic(%{field: value})
      {:ok, %Topic{}}

      iex> create_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a topic.

  ## Examples

      iex> update_topic(topic, %{field: new_value})
      {:ok, %Topic{}}

      iex> update_topic(topic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a topic.

  ## Examples

      iex> delete_topic(topic)
      {:ok, %Topic{}}

      iex> delete_topic(topic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking topic changes.

  ## Examples

      iex> change_topic(topic)
      %Ecto.Changeset{data: %Topic{}}

  """
  def change_topic(%Topic{} = topic, attrs \\ %{}) do
    Topic.changeset(topic, attrs)
  end

  alias Humbug.Discussions.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  def list_posts(%Topic{id: topic_id}) do
    Post
    |> where(topic_id: ^topic_id)
    |> Repo.all()
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def create_post(%Topic{id: topic_id}, %User{id: author_id}, message) do
    %Post{}
    |> Post.changeset(%{
      topic_id: topic_id,
      author_id: author_id,
      message: message
    })
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end
end
