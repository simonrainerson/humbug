defmodule Humbug.RoomsTest do
  use Humbug.DataCase

  alias Humbug.Discussions
  alias Humbug.Users

  describe "rooms" do
    alias Humbug.Discussions.Room

    import Humbug.DiscussionsFixtures
    import Humbug.UsersFixtures

    @invalid_attrs %{name: nil}

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert Discussions.list_rooms() |> Repo.preload(:topics) == [room]
    end

    test "list_rooms_with_member/2 returns all rooms where user is member" do
      room1 = room_fixture(name: "room1")
      room2 = room_fixture(name: "room2")
      room3 = room_fixture(name: "room3")
      member1 = user_fixture()
      member2 = user_fixture()
      Discussions.add_user_to_room(room1, member1)
      Discussions.add_user_to_room(room3, member1)
      Discussions.add_user_to_room(room2, member2)
      Discussions.add_user_to_room(room3, member2)
      member1_rooms = Discussions.list_rooms_with_member(member1) |> Enum.map(& &1.id)
      member2_rooms = Discussions.list_rooms_with_member(member2) |> Enum.map(& &1.id)
      assert member1_rooms == [room1.id, room3.id]
      assert member2_rooms == [room2.id, room3.id]
    end

    test "list_rooms_with_owner/2 returns all rooms where user is owner" do
      owner = user_fixture()
      # seed DB with room with other owner
      room_fixture()
      {:ok, my_room1} = Discussions.create_room(%{name: "room1", owner_id: owner.id})
      {:ok, my_room2} = Discussions.create_room(%{name: "room2", owner_id: owner.id})
      rooms = Discussions.list_rooms_with_owner(owner) |> Enum.map(& &1.id)
      assert rooms == [my_room1.id, my_room2.id]
    end

    test "list_rooms/1 with user returns all rooms where user is member or owner" do
      owner = user_fixture()
      other_room = room_fixture()
      {:ok, my_room1} = Discussions.create_room(%{name: "room1", owner_id: owner.id})
      Discussions.add_user_to_room(other_room, owner)
      rooms = Discussions.list_rooms(owner) |> Repo.preload(:topics)
      assert rooms == [my_room1, other_room]
    end

    test "list_rooms/1 with string returns a case insentisive filtered list of rooms" do
      room_fixture(name: "room")
      room_fixture(name: "broom")
      room_fixture(name: "double RoOm!")
      room_fixture(name: "cardboard")
      rooms = Discussions.list_rooms("room") |> Enum.map(&(&1.name))
      assert "room" in rooms
      assert "broom" in rooms
      assert "double RoOm!" in rooms
      assert "cardboard" not in rooms

      # Check that empty filter returns all rooms
      all_rooms = Discussions.list_rooms("") |> Enum.map(&(&1.name))
      assert length(all_rooms) == 4
    end

    test "add_user_to_room/2 makes a user a member of a room" do
      member = user_fixture()
      room = room_fixture()
      Discussions.add_user_to_room(room, member)
      # Check that we don't get an error if adding again
      Discussions.add_user_to_room(room, member)
      room = Repo.preload(room, :members)
      assert member in room.members
    end

    test "add_users_to_room/2 makes all users a member of a room" do
      member1 = user_fixture(name: "Mel Loewe")
      member2 = user_fixture(name: "Paige Turner")
      room = room_fixture()
      Discussions.add_users_to_room(room, [member1, member2])
      room = Repo.preload(room, :members)
      assert room.members == [member1, member2]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Discussions.get_room!(room.id) |> Repo.preload(:topics) == room
    end

    test "find_room/1 returns a room with the given name" do
      owner = user_fixture()
      {:ok, room1} = Discussions.create_room(%{name: "kitchen", owner_id: owner.id})
      {:ok, room2} = Discussions.create_room(%{name: "living room", owner_id: owner.id})
      assert Discussions.find_room("kitchen") |> Repo.preload(:topics) == room1
      assert Discussions.find_room("living room") |> Repo.preload(:topics) == room2
      assert is_nil(Discussions.find_room("bed room"))
    end

    test "create_room/1 with valid data creates a room" do
      {:ok, user} = Users.create_user(%{name: "Carrie Oakey"})

      valid_attrs = %{
        name: "Music",
        owner_id: user.id,
        banner: "Sing a long!",
        description: "Here we discuss music related topics."
      }

      assert {:ok, %Room{} = room} = Discussions.create_room(valid_attrs)
      assert room.name == "Music"
      assert room.banner == "Sing a long!"
      assert room.description == "Here we discuss music related topics."
      assert room.owner_id == user.id
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Discussions.create_room(@invalid_attrs)
    end

    test "create_room/1 twice with the same name returns error changeset the second time" do
      user = user_fixture()
      assert {:ok, %Room{}} = Discussions.create_room(%{name: "Room", owner_id: user.id})

      assert {:error, %Ecto.Changeset{}} =
               Discussions.create_room(%{name: "Room", owner_id: user.id})
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture(banner: ":)", description: "yes.")
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Room{} = room} = Discussions.update_room(room, update_attrs)
      assert room.name == "some updated name"
      assert room.banner == ":)"
      assert room.description == "yes."
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Discussions.update_room(room, @invalid_attrs)
      assert room == Discussions.get_room!(room.id) |> Repo.preload(:topics)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Discussions.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Discussions.get_room!(room.id) end
    end

    test "update_banner/2 updates the banner of the room" do
      room = room_fixture()
      room |> Discussions.update_banner("This is the new banner")

      assert Discussions.get_room!(room.id).banner == "This is the new banner"
    end

    test "update_description/2 updates the banner of the room" do
      room = room_fixture()
      room |> Discussions.update_description("This is the new description")

      assert Discussions.get_room!(room.id).description == "This is the new description"
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Discussions.change_room(room)
    end
  end
end
