defmodule HumbugWeb.Components do
  use Phoenix.Component
  import Phoenix.HTML

  @doc """
  Renders in input field.
  """
  attr(:value, :any)
  attr(:text, :string, default: "")

  def text_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns = assign(assigns, :name, field.name)

    ~H"""
    <div phx-feedback-for={@name}>
      <input
        type="text"
        name={@name}
        value={@text}
        phx-blur="cancel-input"
        phx-key="Escape"
        phx-keydown="cancel-input"
        class={[
          "w-full text-left phx-submit-loading:opacity-75 py-2 px-3",
          "text-sm font-semibold leading-6 text-black active:text-white/80"
        ]}
        autofocus
      />
    </div>
    """
  end

  @doc """
  Renders a list of buttons and a button to reveal an input to create new item
  """
  attr(:item_type, :string, required: true)
  attr(:items, :list, required: true)
  attr(:new, :string, default: nil)
  attr(:backgroundcolor, :string, default: "bg-gray-600")
  attr(:activecolor, :string, default: "bg-gray-800")
  attr(:current, :string, default: nil)
  attr(:class, :string, default: nil)

  def button_list(assigns) do
    ~H"""
    <ul>
      <%= for item <- @items do %>
        <li>
          <button
            class={[
              (!is_nil(@current) && @current.name == item && @activecolor) || @backgroundcolor
              | [
                  "w-full text-left h-8 my-[1px] px-2 rounded-l-lg ",
                  "hover:font-extrabold hover:py-1",
                  "hover:#{@activecolor}",
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
      <%= if is_nil(@new) do %>
        <li>
          <button
            phx-click={"new-" <> @item_type}
            class={[
              "w-full py-1 rounded-l-lg ",
              "hover:font-extrabold",
              @backgroundcolor,
              "hover:#{@activecolor}"
            ]}
          >
            Create New <%= String.capitalize(@item_type) %>
          </button>
        </li>
      <% else %>
        <li>
          <.form for={@new} phx-submit={"create-new-" <> @item_type}>
            <.text_input type="text" field={@new[:value]} />
          </.form>
        </li>
      <% end %>
    </ul>
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
      backgroundcolor="bg-gray-600"
      hovercolor={(is_nil(@room) && "hover:bg-gray-800") || "hover:bg-gray-700"}
      activecolor={(is_nil(@room) && "bg-gray-800") || "bg-gray-700"}
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
      backgroundcolor="bg-gray-700"
      activecolor="bg-gray-800"
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
          <button
            type="image"
            src="/images/pen-to-square-solid.svg"
            class="group h-8 w-8 stroke-white hover:bg-gray-800"
            phx-click="edit-banner"
          >
            <svg viewBox="0 0 512 512" class="w-5 fill-gray-800 group-hover:fill-white m-auto">
              <path d="M471.6 21.7c-21.9-21.9-57.3-21.9-79.2 0L362.3 51.7l97.9 97.9 30.1-30.1c21.9-21.9 21.9-57.3 0-79.2L471.6 21.7zm-299.2 220c-6.1 6.1-10.8 13.6-13.5 21.9l-29.6 88.8c-2.9 8.6-.6 18.1 5.8 24.6s15.9 8.7 24.6 5.8l88.8-29.6c8.2-2.7 15.7-7.4 21.9-13.5L437.7 172.3 339.7 74.3 172.4 241.7zM96 64C43 64 0 107 0 160V416c0 53 43 96 96 96H352c53 0 96-43 96-96V320c0-17.7-14.3-32-32-32s-32 14.3-32 32v96c0 17.7-14.3 32-32 32H96c-17.7 0-32-14.3-32-32V160c0-17.7 14.3-32 32-32h96c17.7 0 32-14.3 32-32s-14.3-32-32-32H96z" />
            </svg>
          </button>
        </div>
      <% else %>
        <.form for={@edit_banner_form} phx-submit="update-banner" class="w-full">
          <div class="w-full">
            <.text_input
              type="text"
              field={@edit_banner_form[:banner]}
              value={@banner}
              text={@banner}
              class="px-4 py-0 h-8"
            />
          </div>
        </.form>
      <% end %>
    </div>
    """
  end
end
