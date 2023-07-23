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
end
