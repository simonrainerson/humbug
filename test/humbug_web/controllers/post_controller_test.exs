defmodule HumbugWeb.PostControllerTest do
  use HumbugWeb.ConnCase

  import Humbug.{DiscussionsFixtures, UsersFixtures}

  @invalid_attrs %{
    "api_key" => "3a84ed9e-3ecc-11ee-be56-0242ac120002",
    "topic_id" => nil,
    "message" => "This is bad"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create post" do
    test "renders post when data is valid", %{conn: conn} do
      topic = topic_fixture()
      user_fixture()
      author = user_fixture()

      conn =
        post(conn, ~p"/api/post", %{
          api_key: author.api_key,
          topic_id: topic.id,
          message: "This is good"
        })

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert id in (Humbug.Discussions.list_posts() |> Enum.map(& &1.id))
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = user_fixture()
      conn = post(conn, ~p"/api/post", @invalid_attrs)
      assert json_response(conn, 400)["errors"] != %{}

      conn =
        post(conn, ~p"/api/post", %{
          "api_key" => user.api_key,
          "topic_id" => nil,
          "message" => "This is also bad."
        })

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
