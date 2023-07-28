defmodule HumbugWeb.HumbugLiveTest do
  use HumbugWeb.ConnCase
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  describe "Test Live View. " do
    test "Disconnected and connected mount", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "<div"

      {:ok, _view, _html} = live(conn)
    end

    test "Click new room displays the form", %{conn: conn} do
      conn = get(conn, "/")
      {:ok, view, html} = live(conn)

      assert html =~ "phx-submit=\"create-new-room\"" == false

      assert view
             |> element("button", "Create New Room")
             |> render_click() =~ "phx-submit=\"create-new-room\""
    end
  end
end
