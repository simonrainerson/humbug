defmodule Humbug.TopicsTest do
  use Humbug.DataCase

  alias Humbug.Discussions

  describe "topics" do
    alias Humbug.Discussions.Topic

    import Humbug.DiscussionsFixtures
    import Humbug.UsersFixtures

    @invalid_attrs %{name: nil, rooms: nil}

    test "list_topics/0 returns all topics" do
      topic = topic_fixture()

      topics =
        Discussions.list_topics()
        |> Repo.preload(:rooms)

      assert topics == [topic]
    end

    test "list_topics/1 with a room returns all topics in that room" do
      room = room_fixture() |> Repo.preload(:owner)

      {:ok, topic_1} =
        Discussions.create_topic(%{name: "topic", owner_id: room.owner.id, rooms: [room]})

      {:ok, topic_2} =
        Discussions.create_topic(%{name: "bopic", owner_id: room.owner.id, rooms: [room]})

      {:ok, topic_3} =
        Discussions.create_topic(%{name: "hopic", owner_id: room.owner.id, rooms: [room]})

      topic_4 = topic_fixture()
      topic_ids = Discussions.list_topics(room) |> Enum.map(& &1.id)
      assert topic_1.id in topic_ids
      assert topic_2.id in topic_ids
      assert topic_3.id in topic_ids
      assert topic_4.id not in topic_ids
    end

    test "get_topic!/1 returns the topic with given id" do
      topic = topic_fixture()

      got_topic =
        Discussions.get_topic!(topic.id)
        |> Repo.preload(:rooms)

      assert got_topic == topic
    end

    test "find_topics/1 returns a list of topics" do
      owner = user_fixture()
      {:ok, topic1} = Discussions.create_topic(%{name: "something", owner_id: owner.id})
      {:ok, topic2} = Discussions.create_topic(%{name: "something else", owner_id: owner.id})
      {:ok, topic3} = Discussions.create_topic(%{name: "something", owner_id: owner.id})
      topics = Discussions.find_topics("something")
      assert topic1 in topics
      assert topic2 not in topics
      assert topic3 in topics
    end

    test "find_topics/2 returns a list of topics beloning to room" do
      room = room_fixture() |> Repo.preload(:owner)

      {:ok, topic1} =
        Discussions.create_topic(%{name: "something", rooms: [room], owner_id: room.owner.id})

      {:ok, topic2} = Discussions.create_topic(%{name: "something", owner_id: room.owner.id})

      {:ok, topic3} =
        Discussions.create_topic(%{name: "something", rooms: [room], owner_id: room.owner.id})

      topics = Enum.map(Discussions.find_topics("something", room), & &1.id)
      assert topic1.id in topics
      assert topic2.id not in topics
      assert topic3.id in topics
    end

    test "create_topic/1 with valid data creates a topic" do
      room = room_fixture() |> Repo.preload(:owner)

      valid_attrs = %{
        name: "Cardboard",
        rooms: [room],
        owner_id: room.owner.id
      }

      assert {:ok, %Topic{} = topic} = Discussions.create_topic(valid_attrs)
      assert topic.name == "Cardboard"
    end

    test "create_topic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Discussions.create_topic(@invalid_attrs)
    end

    test "update_topic/2 with valid data updates the topic" do
      topic = topic_fixture()
      room = room_fixture()

      update_attrs = %{
        name: "some updated name",
        rooms: [room | topic.rooms]
      }

      assert {:ok, %Topic{} = topic} = Discussions.update_topic(topic, update_attrs)
      assert topic.name == "some updated name"
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      assert {:error, %Ecto.Changeset{}} = Discussions.update_topic(topic, @invalid_attrs)
      assert topic == Discussions.get_topic!(topic.id) |> Repo.preload(:rooms)
    end

    test "delete_topic/1 deletes the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{}} = Discussions.delete_topic(topic)
      assert_raise Ecto.NoResultsError, fn -> Discussions.get_topic!(topic.id) end
    end

    test "change_topic/1 returns a topic changeset" do
      topic = topic_fixture()
      assert %Ecto.Changeset{} = Discussions.change_topic(topic)
    end
  end
end
