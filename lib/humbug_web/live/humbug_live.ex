defmodule HumbugWeb.HumbugLive do
  use Phoenix.LiveView
  import Ecto
  alias Humbug.Discussions
  require Logger

  defp reset_socket(socket) do
    socket
    |> assign(
      new_room_form: nil,
      new_topic_form: nil,
      edit_banner_form: nil
    )
  end

  @impl true
  def mount(_params, _args, socket) do
    user_id = Enum.random(1..3)

    user =
      try do
        Humbug.Users.get_user!(user_id)
      rescue
        Ecto.NoResultsError ->
          Humbug.Repo.insert!(%Humbug.Users.User{id: user_id, name: "Molly Kuehl"})
      end

    Logger.debug(user.name <> " connected!")

    {:ok,
     socket
     |> assign(
       rooms: Humbug.Discussions.list_rooms(user) |> Enum.map(& &1.name),
       user: user
     )}
  end

  defp assign_room(socket, params) do
    case params |> Map.get("room") do
      nil ->
        assign(socket, room: nil)

      room_name ->
        case Discussions.find_room(room_name) do
          nil ->
            socket
            |> assign(room: nil)
            |> put_flash(:error, "Room " <> room_name <> " not found!")
            |> push_patch(to: "/")

          room ->
            assign(socket, room: room)
        end
    end
  end

  defp assign_topic(socket, params) do
    if is_nil(socket.assigns.room) do
      socket
    else
      case params |> Map.get("topic") |> Discussions.find_topics(socket.assigns.room) do
        [topic | _] ->
          socket |> assign(topic: topic)

        _ ->
          case Discussions.find_topics("Chat", socket.assigns.room) do
            [topic | _] ->
              socket
              |> assign(topic: topic)
              |> push_patch(to: "/" <> socket.assigns.room.name <> "/Chat")

            _ ->
              Logger.error("Error: Room " <> socket.assigns.room.name <> " has no topics")

              socket
              |> put_flash(:error, "Room" <> socket.assigns.room.name <> "has not topics")
              |> push_patch("/")
              |> assign(topic: nil)
          end
      end
    end
  end

  defp assign_topics(socket) do
    topics = Discussions.list_topics(socket.assigns.room) |> Enum.map(& &1.name)
    assign(socket, topics: topics)
  end

  defp assign_chat_form(socket) do
    case Map.get(socket.assigns, :topic) do
      nil -> socket
      topic -> socket |> assign(chat_form: to_form(Ecto.Changeset.change(%Discussions.Post{})))
    end
  end

  defp group_posts(post, []) do
    [{post.author, [post.message]}]
  end

  defp group_posts(post, [{author, posts} | rest]) do
    if post.author == author do
      [{author, [post.message | posts]} | rest]
    else
      [{post.author, [post.message]}, {author, posts} | rest]
    end
  end

  defp assign_posts(socket) do
    case Map.get(socket.assigns, :topic) do
      nil ->
        socket

      topic ->
        assign(socket,
          posts:
            Discussions.list_posts(topic)
            |> Humbug.Repo.preload(:author)
            |> Enum.reduce(
              [],
              &group_posts(&1, &2)
            )
        )
    end
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {
      :noreply,
      socket
      |> reset_socket
      |> assign_room(params)
      |> assign_topic(params)
      |> assign_topics()
      |> assign_posts()
      |> assign_chat_form()
    }
  end

  @impl true
  def handle_event("new-room", _params, socket) do
    {:noreply, assign(socket, new_room_form: to_form(Ecto.Changeset.change(%Discussions.Room{})))}
  end

  @impl true
  def handle_event("cancel-input", _params, socket) do
    {:noreply, reset_socket(socket)}
  end

  @impl true
  def handle_event("create-new-room", %{"room" => %{"value" => name}}, socket) do
    socket =
      Discussions.create_room(%{name: name, owner_id: socket.assigns.user.id})
      |> case do
        {:ok, room} ->
          socket
          |> assign(room: room, rooms: Enum.sort([room.name | socket.assigns.rooms]))
          |> push_patch(to: "/" <> room.name)

        {:error, %Ecto.Changeset{errors: errors}} ->
          error =
            case errors |> Keyword.get(:name) do
              {error, _} ->
                error

              _ ->
                Logger.error("Create New Room Error:")
                Logger.error(errors)
                "Internal Error"
            end

          socket |> put_flash(:error, error)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("new-topic", _params, socket) do
    {:noreply,
     assign(socket, new_topic_form: to_form(Ecto.Changeset.change(%Discussions.Topic{})))}
  end

  @impl true
  def handle_event("create-new-topic", %{"topic" => %{"value" => name}}, socket) do
    socket =
      Discussions.create_topic(%{
        name: name,
        owner_id: socket.assigns.user.id,
        rooms: [socket.assigns.room]
      })
      |> case do
        {:ok, topic} ->
          socket
          |> assign(topic: topic, topics: Enum.sort([topic.name | socket.assigns.topics]))
          |> push_patch(to: "/" <> socket.assigns.room.name <> "/" <> topic.name)

        {:error, %Ecto.Changeset{errors: errors}} ->
          error =
            case errors |> Keyword.get(:name) do
              {error, _} ->
                error

              _ ->
                Logger.error("Create New Topic Error:")
                Logger.error(errors)
                "Internal Error"
            end

          socket |> put_flash(:error, error)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("go-to-room", %{"value" => room_name}, socket) do
    {:noreply, socket |> push_patch(to: "/" <> room_name)}
  end

  @impl true
  def handle_event("go-to-topic", %{"value" => topic_name}, socket) do
    {:noreply, socket |> push_patch(to: "/" <> socket.assigns.room.name <> "/" <> topic_name)}
  end

  @impl true
  def handle_event("edit-banner", _params, socket) do
    {:noreply,
     socket |> assign(edit_banner_form: to_form(Ecto.Changeset.change(%Discussions.Room{})))}
  end

  @impl true
  def handle_event("update-banner", %{"room" => %{"banner" => banner}}, socket) do
    socket =
      case Discussions.update_banner(socket.assigns.room, banner) do
        {:ok, room} ->
          socket |> assign(room: room)

        {:error, %Ecto.Changeset{errors: errors}} ->
          error =
            case errors |> Keyword.get(:banner) do
              {error, _} ->
                error

              _ ->
                Logger.error("Edit Banner Error:")
                Logger.error(errors)
                "Internal Error"
            end

          socket |> put_flash(:error, error)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("post-message", %{"post" => %{"message" => message}}, socket) do
    {:noreply,
     case Discussions.create_post(socket.assigns.topic, socket.assigns.user, message) do
       {:ok, post} ->
         socket |> assign(
          chat_form: to_form(Ecto.Changeset.change(%Discussions.Post{})),
          posts: group_posts(post |> Humbug.Repo.preload(:author), socket.assigns.posts)
          )

       {:error, %Ecto.Changeset{errors: errors}} ->
         error =
           case errors |> Keyword.get(:message) do
             {error, _} ->
               error

             _ ->
               Logger.error("Post Message Error:")
               Logger.error(errors)
               "Internal Error"
           end

         socket |> put_flash(:error, error)
     end}
  end

  @impl true
  def handle_event(
        "change",
        %{"_target" => ["post", "message"], "post" => %{"message" => message}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(chat_form: to_form(Ecto.Changeset.change(%Discussions.Post{message: message})))}
  end

  @impl true
  def handle_event("change", params, socket) do
    {:noreply, socket}
  end
end
