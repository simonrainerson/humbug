defmodule Humbug.DiscussionsTest do
  use Humbug.DataCase

  alias Humbug.Discussions

  describe "posts" do
    alias Humbug.Discussions.Post

    import Humbug.DiscussionsFixtures

    @invalid_attrs %{message: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Discussions.list_posts() == [post]
    end

    test "list_posts/1 returns all posts in a topic" do
      topic = topic_fixture() |> Repo.preload(:owner)
      {:ok, post1} = Discussions.create_post(topic, topic.owner, "Bla bla bla")
      {:ok, post2} = Discussions.create_post(topic, topic.owner, "Bla blu bla")
      {:ok, post3} = Discussions.create_post(topic, topic.owner, "Ble ble bla")
      other_post = post_fixture()

      posts = Discussions.list_posts(topic)
      assert Enum.member?(posts, post1)
      assert Enum.member?(posts, post2)
      assert Enum.member?(posts, post3)
      assert !Enum.member?(posts, other_post)
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Discussions.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      topic = topic_fixture() |> Repo.preload(:owner)
      valid_attrs = %{message: "some message", topic_id: topic.id, author_id: topic.owner.id}

      assert {:ok, %Post{} = post} = Discussions.create_post(valid_attrs)
      assert post.message == "some message"
    end

    test "create_post/3 with valid data creates a post" do
      topic = topic_fixture() |> Repo.preload(:owner)
      assert {:ok, %Post{} = post} = Discussions.create_post(topic, topic.owner, "Some text")
      assert post.message == "Some text"
    end

    test "create_post/1 with invalid data returns error changeset" do
      {:error, %Ecto.Changeset{errors: errors}} = Discussions.create_post(@invalid_attrs)
      {_, [validation: :required]} = Keyword.get(errors, :message)
      {_, [validation: :required]} = Keyword.get(errors, :author_id)
      {_, [validation: :required]} = Keyword.get(errors, :topic_id)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{message: "some updated message"}

      assert {:ok, %Post{} = post} = Discussions.update_post(post, update_attrs)
      assert post.message == "some updated message"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Discussions.update_post(post, @invalid_attrs)
      assert post == Discussions.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Discussions.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Discussions.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Discussions.change_post(post)
    end
  end
end
