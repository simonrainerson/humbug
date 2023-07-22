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
end
