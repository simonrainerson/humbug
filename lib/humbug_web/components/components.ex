defmodule HumbugWeb.Components do
  use Phoenix.Component
  import Phoenix.HTML

  @doc """
  Button with a search icon
  """
  attr(:click, :string)
  attr(:color, :string, default: "gray-800")
  attr(:hover, :string, default: "gray-800")

  def search_button(assigns) do
    ~H"""
    <button class={"group h-8 w-8 stroke-white hover:bg-#{@hover} rounded-full"} phx-click={@click}>
      <svg viewBox="0 0 512 512" class={"w-5 fill-#{@color} group-hover:fill-white m-auto"}>
        <!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. -->
        <path d="M416 208c0 45.9-14.9 88.3-40 122.7L502.6 457.4c12.5 12.5 12.5 32.8 0 45.3s-32.8 12.5-45.3 0L330.7 376c-34.4 25.2-76.8 40-122.7 40C93.1 416 0 322.9 0 208S93.1 0 208 0S416 93.1 416 208zM208 352a144 144 0 1 0 0-288 144 144 0 1 0 0 288z" />
      </svg>
    </button>
    """
  end

  @doc """
  Button with a pen icon
  """
  attr(:click, :string)
  attr(:hover, :string, default: "gray-800")
  attr(:color, :string, default: "gray-800")

  def edit_button(assigns) do
    ~H"""
    <button class={"group h-8 w-8 stroke-white hover:bg-#{@hover}"} phx-click={@click}>
      <svg viewBox="0 0 512 512" class={"w-5 fill-#{@color} group-hover:fill-white m-auto"}>
        <!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. -->
        <path d="M471.6 21.7c-21.9-21.9-57.3-21.9-79.2 0L362.3 51.7l97.9 97.9 30.1-30.1c21.9-21.9 21.9-57.3 0-79.2L471.6 21.7zm-299.2 220c-6.1 6.1-10.8 13.6-13.5 21.9l-29.6 88.8c-2.9 8.6-.6 18.1 5.8 24.6s15.9 8.7 24.6 5.8l88.8-29.6c8.2-2.7 15.7-7.4 21.9-13.5L437.7 172.3 339.7 74.3 172.4 241.7zM96 64C43 64 0 107 0 160V416c0 53 43 96 96 96H352c53 0 96-43 96-96V320c0-17.7-14.3-32-32-32s-32 14.3-32 32v96c0 17.7-14.3 32-32 32H96c-17.7 0-32-14.3-32-32V160c0-17.7 14.3-32 32-32h96c17.7 0 32-14.3 32-32s-14.3-32-32-32H96z" />
      </svg>
    </button>
    """
  end

  @doc """
  Button for cancelling things
  """
  attr(:click, :string)
  attr(:hover, :string, default: "gray-800")
  attr(:color, :string, default: "gray-800")

  def cancel_button(assigns) do
    ~H"""
    <button class={"group h-8 w-8 stroke-white hover:bg-#{@hover} rounded-full"} phx-click={@click}>
      <svg viewBox="0 0 512 512" class={"w-6 fill-#{@color} group-hover:fill-white m-auto"}>
        <!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. -->
        <path d="M342.6 150.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192 210.7 86.6 105.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L146.7 256 41.4 361.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192 301.3 297.4 406.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.3 256 342.6 150.6z" />
      </svg>
    </button>
    """
  end

  @doc """
  Renders in input field.
  """
  attr(:field, Phoenix.HTML.FormField)
  attr(:text, :string, default: "")
  attr(:class, :string, default: "")
  attr(:blurrable, :boolean, default: true)

  def text_input(assigns) do
    ~H"""
    <div phx-feedback-for={@field.name}>
      <input
        id={@field.name}
        type="text"
        name={@field.name}
        value={@text}
        autocomplete="off"
        phx-blur={(@blurrable && "cancel-input") || nil}
        phx-key="Escape"
        phx-keydown="cancel-input"
        phx-change="change"
        class={[
          "w-full text-left phx-submit-loading:opacity-75 py-2 px-3",
          "text-sm font-semibold leading-6 text-black active:text-white/80",
          @class
        ]}
        autofocus
      />
    </div>
    """
  end

  @doc """
  Renders a list of buttons
  """
  slot(:inner_block)

  attr(:item_type, :string, required: true)
  attr(:items, :list, required: true)
  attr(:backgroundcolor, :string, default: "gray-600")
  attr(:activecolor, :string, default: "gray-800")
  attr(:current, :string, default: nil)
  attr(:class, :string, default: nil)

  def list(assigns) do
    ~H"""
    <ul>
      <%= for item <- @items do %>
        <li>
          <button
            class={[
              (!is_nil(@current) && @current.name == item && "bg-" <> @activecolor) ||
                "bg-" <> @backgroundcolor
              | [
                  "w-full text-left h-8 my-[1px] px-2 rounded-l-lg ",
                  "hover:font-extrabold hover:py-1",
                  "hover:bg-#{@activecolor}",
                  @class
                ]
            ]}
            phx-click={"go-to-#{@item_type}"}
            value={item}
          >
            <%= item %>
          </button>
        </li>
      <% end %>
      <li>
        <%= render_slot(@inner_block) %>
      </li>
    </ul>
    """
  end

  @doc """
  Renders a list of buttons and a button to reveal an input to create new item
  """
  attr(:item_type, :string, required: true)
  attr(:items, :list, required: true)
  attr(:new, :string, default: nil)
  attr(:backgroundcolor, :string, default: "gray-600")
  attr(:activecolor, :string, default: "gray-800")
  attr(:current, :string, default: nil)
  attr(:class, :string, default: nil)

  def button_list(assigns) do
    ~H"""
    <.list
      item_type={@item_type}
      items={@items}
      backgroundcolor={@backgroundcolor}
      activecolor={@activecolor}
      current={@current}
      class={@class}
    >
      <.new_item
        new={@new}
        item_type={@item_type}
        backgroundcolor={@backgroundcolor}
        activecolor={@activecolor}
      />
    </.list>
    """
  end

  @doc """
  Button to create a new item or form to name it
  """

  attr(:new, :string)
  attr(:item_type, :string)
  attr(:backgroundcolor, :string, default: "gray-600")
  attr(:activecolor, :string, default: "gray-800")

  def new_item(assigns) do
    ~H"""
    <%= if is_nil(@new) do %>
      <button
        phx-click={"new-" <> @item_type}
        class={[
          "w-full py-1 rounded-l-lg ",
          "hover:font-extrabold",
          "bg-" <> @backgroundcolor,
          "hover:bg-#{@activecolor}"
        ]}
      >
        Create New <%= String.capitalize(@item_type) %>
      </button>
    <% else %>
      <.form for={@new} phx-submit={"create-new-" <> @item_type}>
        <.text_input field={@new[:value]} />
      </.form>
    <% end %>
    """
  end

  @doc """
  Render a list of room buttons with a create new room button.
  """

  attr(:rooms, :list, required: true)
  attr(:room, :string, default: nil)
  attr(:new_room_form, :string, default: nil)

  def room_list(assigns) do
    ~H"""
    <.button_list
      items={@rooms}
      item_type="room"
      current={@room}
      new={@new_room_form}
      backgroundcolor="gray-600"
      activecolor={(is_nil(@room) && "gray-800") || "gray-700"}
    />
    """
  end

  @doc """
  Render a list of room buttons filtered by search.
  """

  attr(:search_rooms, :list, required: true)
  attr(:room, :string, default: nil)
  attr(:search_rooms_form, :string, default: nil)

  def search_room_list(assigns) do
    ~H"""
    <.form for={@search_rooms_form} phx-change="search_rooms" phx-submit="goto-room">
      <.text_input field={@search_rooms_form[:text]} text="" blurrable={false} />
    </.form>
    <.list
      items={@search_rooms}
      item_type="room"
      current={@room}
      backgroundcolor="gray-600"
      activecolor={(is_nil(@room) && "gray-800") || "gray-700"}
    />
    """
  end

  @doc """
  Render a list of topic buttons with a create new topic button.
  """

  attr(:topics, :list, required: true)
  attr(:topic, :string, default: nil)
  attr(:new_topic_form, :string, default: nil)

  def topic_list(assigns) do
    ~H"""
    <.button_list
      items={@topics}
      item_type="topic"
      new={@new_topic_form}
      current={@topic}
      backgroundcolor="gray-700"
      activecolor="gray-800"
    />
    """
  end

  @doc """
  Shows the banner and lets user edit it.
  """
  attr(:banner, :string, default: "")
  attr(:edit_banner_form, :string, default: nil)

  def edit_banner(assigns) do
    ~H"""
    <div class="flex flex-row w-full h-full">
      <%= if is_nil(@edit_banner_form) do %>
        <p class="px-4 my-auto">
          <%= raw(@banner) %>
        </p>
        <div class="ml-auto">
          <.edit_button click="edit-banner" />
        </div>
      <% else %>
        <.form for={@edit_banner_form} phx-submit="update-banner" class="w-full">
          <div class="w-full">
            <.text_input field={@edit_banner_form[:banner]} text={@banner} class="px-4 py-0 h-8" />
          </div>
        </.form>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders an input field for chat messages
  """
  attr(:chat_form, :string)
  attr(:is_member, :boolean, default: false)

  def message_input(assigns) do
    ~H"""
    <%= if @is_member do %>
      <.form for={@chat_form} phx-submit="post-message">
        <.text_input field={@chat_form[:message]} text="" />
      </.form>
    <% else %>
      <button class="w-full h-10 font-bold text-xl" phx-click="join-room">
        Join Room
      </button>
    <% end %>
    """
  end

  @doc """

  """
  attr(:messages, :list, required: true)
  attr(:username, :string, required: true)
  attr(:icon, :string, default: nil)

  def messages_by_user(assigns) do
    ~H"""
    <div class="flex flex-row">
      <%= if !is_nil(@username) do %>
        <div class="w-10">
          <%= if is_nil(@icon) do %>
            <div class="rounded-full bg-gray-900 text-yellow-800 h-10 flex justify-center items-center font-bold text-2xl">
              <%= @username |> String.first() |> String.capitalize() %>
            </div>
          <% else %>
            <img src={@icon} />
          <% end %>
        </div>
      <% end %>
      <div class="w-full">
        <%= if !is_nil(@username) do %>
          <div class="mx-2 text-lg underline"><%= @username %>:</div>
        <% end %>
        <div class="flex flex-col-reverse w-full">
          <%= for message <- @messages do %>
            <div class="ml-2 hover:bg-gray-900 w-full">
              <p class="break-all"><%= message %></p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a list of messages maps, containing messages and user, with name and possibly icon.
  """

  attr(:messages, :list, default: [])

  def messages(assigns) do
    ~H"""
    <div class="flex flex-col-reverse">
      <%= for {author, messages} <- @messages do %>
        <.messages_by_user messages={messages} username={author.name} icon={Map.get(author, :icon)} />
      <% end %>
    </div>
    """
  end

  @doc """
  Renders the room info with description and members list
  """

  attr(:description, :string, default: "")
  attr(:owner, :string)
  attr(:members, :list, default: [])

  def room_info(assigns) do
    ~H"""
    <h1 class="font-bold text-center">Room Info</h1>
    <div>
      <h1 class="font-bold">Description</h1>
      <p class="pl-2"><%= @description %></p>
    </div>
    <div>
      <h1 class="font-bold">Members</h1>
      <ul class="pl-4">
        <li><%= @owner.name %> (Owner)</li>
        <%= for member <- @members do %>
          <li>
            <%= member.name %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
