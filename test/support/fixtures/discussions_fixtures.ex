defmodule Humbug.DiscussionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Humbug.Discussions` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, owner} = Humbug.Users.create_user(%{name: "Max Power"})

    {:ok, room} =
      attrs
      |> Enum.into(%{
        name: "Roomy",
        owner_id: owner.id
      })
      |> Humbug.Discussions.create_room()

    room
  end

  @doc """
  Generate a topic.
  """
  def topic_fixture(attrs \\ %{}) do
    {:ok, owner} = Humbug.Users.create_user(%{name: "Reid Enright"})
    room = Humbug.Repo.insert!(%Humbug.Discussions.Room{name: "Roomba", owner_id: owner.id})

    {:ok, topic} =
      attrs
      |> Enum.into(%{
        name: "Tropic",
        owner_id: owner.id,
        rooms: [room]
      })
      |> Humbug.Discussions.create_topic()

    topic
  end

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, author} = Humbug.Users.create_user(%{name: "Sal A. Mander"})
    room = Humbug.Repo.insert!(%Humbug.Discussions.Room{name: "Roomy", owner_id: author.id})

    {:ok, topic} =
      attrs
      |> Enum.into(%{
        name: "topical",
        owner_id: author.id,
        rooms: [room]
      })
      |> Humbug.Discussions.create_topic()

    {:ok, post} =
      attrs
      |> Enum.into(%{
        message: "some message",
        topic_id: topic.id,
        author_id: author.id
      })
      |> Humbug.Discussions.create_post()

    post
  end
end
