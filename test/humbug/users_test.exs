defmodule Humbug.UsersTest do
  use Humbug.DataCase

  alias Humbug.Users

  describe "users" do
    alias Humbug.Users.User

    import Humbug.UsersFixtures

    @long_name %{name: String.duplicate("a", 33)}
    @no_name %{name: ""}

    test "list_users/0 returns all users" do
      user1 = user_fixture()
      user2 = user_fixture()
      all_users = Users.list_users()
      assert Enum.member?(all_users, user1)
      assert Enum.member?(all_users, user2)
    end

    test "get_user_by_api_key returns the user with the given api key" do
      user_fixture()
      user2 = user_fixture()
      user_fixture()
      user = Users.get_user_by_api_key(user2.api_key)
      assert user == user2
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{name: "Polly Ester"}

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.name == "Polly Ester"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user()
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@long_name)
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@no_name)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{name: "Sonny Day"}

      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.name == "Sonny Day"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @long_name)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
