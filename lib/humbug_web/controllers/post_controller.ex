defmodule HumbugWeb.PostController do
  require Logger
  use HumbugWeb, :controller

  alias Humbug.{Discussions, Users}

  action_fallback(HumbugWeb.FallbackController)

  def create(conn, %{"topic_id" => topic_id, "api_key" => api_key, "message" => message}) do
    case Users.get_user_by_api_key(api_key) do
      %Users.User{} = user ->
        with {:ok, %Discussions.Post{} = post} <-
               Discussions.create_post(%{
                 topic_id: topic_id,
                 author_id: user.id,
                 message: message
               }) do
          Phoenix.PubSub.broadcast(Humbug.PubSub, "topic-updates:#{topic_id}", {:add, post})

          conn
          |> put_status(:created)
          |> render(:show, post: post)
        end

      _ ->
        conn
        |> put_status(400)
        |> render(:show, post: %Discussions.Post{})
    end
  end
end
