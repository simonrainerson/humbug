defmodule HumbugWeb.HumbugLiveComponentTest do
  use ExUnit.Case
  use Phoenix.Component
  import Phoenix.LiveViewTest
  alias HumbugWeb.Components

  test "render button_list" do
    assigns = %{}

    fish_list =
      Floki.parse_fragment!(
        rendered_to_string(~H"""
        <Components.button_list item_type="fish" items={["Eel", "Cod", "Shark"]} />
        """)
      )

    [
      {"ul", [],
       [
         {"li", [], eel_button},
         {"li", [], _},
         {"li", [], _},
         {"li", [], [{"button", [{"phx-click", "new-fish"}, _], [new_fish]}]}
       ]}
    ] = Floki.find(fish_list, "ul")

    [
      {"button",
       [
         {"class", _},
         {"phx-click", "go-to-fish"},
         {"value", "Eel"}
       ], [eel_text]}
    ] = eel_button

    assert String.trim(eel_text) == "Eel"

    assert String.trim(new_fish) == "Create New Fish"

    fish_list =
      Floki.parse_fragment!(
        rendered_to_string(~H"""
        <Components.button_list
          item_type="fish"
          items={["Eel", "Cod", "Shark"]}
          new={to_form(Ecto.Changeset.change(%Humbug.Discussions.Room{}))}
        />
        """)
      )

    [{"form", [{"method", "post"}, {"phx-submit", "create-new-fish"}], _}] =
      Floki.find(fish_list, "form")
  end
end
