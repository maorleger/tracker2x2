defmodule Tracker2x2.ElmControllerTest do
  use Tracker2x2.ConnCase
  import Plug.Test

  test "it redirects if the user is not signed in", %{conn: conn} do
    conn = get conn, "/elm"
    response = html_response(conn, 302)
    assert conn.halted
    assert get_flash(conn, :error) == "Please login to continue"
  end

  test "it shows a logout button if the user is logged in", %{conn: conn} do

    conn =
      conn
      |> init_test_session(oauth_email: "maor.leger@example.com")
      |> get("/elm")

    response = html_response(conn, 200)
    assert response =~ "Sign out"
  end
  
  test "edit" do

  end
end
